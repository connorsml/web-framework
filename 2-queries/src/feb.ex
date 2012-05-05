defmodule Feb do
  # This is what the call
  #
  #    use Feb, root: "assets"
  #
  # expands to.
  defmacro __using__(module, opts) do
    root_val = Keyword.get(opts, :root, ".")

    quote do
      import Feb

      def start do
        Feb.start unquote(module)
      end

      defp static_root, do: unquote(root_val)
    end
  end

  def start(module) do
    IO.puts "Executing Feb.start"
    pid = spawn __MODULE__, :init, [module]
    Process.register module, pid
    pid
  end


  def init(module) do
    msg_loop module
  end

  defp msg_loop(module) do
    receive do
    match: { from, { :get, path_with_query } }
      { path, query } = split_path(path_with_query)
      from <- module.handle(:get, path, query)
      msg_loop module

    match: { from, { :post, path, body } }
      from <- module.handle(:post, path, body)
      msg_loop module

    match: { from, { :delete, path } }
      from <- module.handle(:delete, path)
      msg_loop module
    end
  end

  # Return { path, query } where `query` is an orddict.
  def split_path(path_with_query) do
    case Regex.split %r/\?/, path_with_query do
    match: [ path, query ]
      { path, dict_from_query(query) }

    # No query in the path. Return an empty orddict.
    match: [ path ]
      { path, Orddict.new }
    end
  end

  # Split the query of the form `key1=value1&key2=value2...` into separate
  # key-value pairs and put them in an orddict
  defp dict_from_query(query) do
    parts = Regex.split %r/&/, query
    Enum.reduce parts, Orddict.new, fn(kvstr, dict) ->
      [ key, value ] = Regex.split %r/=/, kvstr
      Dict.put dict, key, value
    end
  end

  ###

  defmacro get(path, query, [do: code]) do
    quote do
      def handle(:get, unquote(path), unquote(query)) do
        unquote(code)
      end
    end
  end

  # GET request handler. It has two forms.
  defmacro get(path, [do: code]) do
    quote do
      def handle(:get, unquote(path), _query) do
        unquote(code)
      end
    end
  end

  defmacro get(path, [file: bin]) when is_binary(bin) do
    quote do
      def handle(:get, unquote(path), _query) do
        full_path = File.join([static_root(), unquote(bin)])
        case File.read(full_path) do
        match: { :ok, data }
          { :ok, data }
        else:
          format_error(404)
        end
      end
    end
  end

  # POST request handler
  defmacro post(path, [do: code]) do
    # Disable hygiene so that `_body` is accessible in the client code
    quote hygiene: false do
      def handle(:post, unquote(path), _body) do
        unquote(code)
      end
    end
  end

  # Generic request handler
  #  defmacro handle(path, query, body, block) do
  #    quote do
  #    end
  #  end

  defmacro default_handle do
    quote do
      def handle(method, path, data // "")
      def handle(method, path, data) do
        # Allow only the listed methods
        if not (method in [:get, :post, :delete]) do
          format_error(400)

        # Path should always start with a slash (/)
        elsif: not match?("/" <> _, path)
          format_error(400)

        # Otherwise, the request is assumed to be valid but the requested
        # resource cannot be found
        else:
          format_error(404)
        end
      end
    end
  end

  ###

  # Return a { :error, <binary> } tuple with error description
  def format_error(code) do
    { :error, case code do
    match: 400
      "400 Bad Request"
    match: 404
      "404 Not Found"
    else:
      "503 Internal Server Error"
    end }
  end

  ###

  defmodule API do
    # Client API

    def get(target, path_with_query) do
      call target, { :get, path_with_query }
    end

    def post(target, path, body // "") do
      call target, { :post, path, body }
    end

    def delete(target, path) do
      call target, { :delete, path }
    end

    def call(target, msg) do
      target <- { Process.self(), msg }
      receive do
      match: x
        x
      after: 1000
        :timeout
      end
    end
  end
end
