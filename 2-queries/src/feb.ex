defmodule Feb do
  # This is what the call
  #
  #    use Feb, root: "assets"
  #
  # expands to.
  defmacro __using__(module, opts) do
    root_val = Keyword.get(opts, :root, ".")

    quote do
      import Feb, only: [get: 2, get: 3, post: 2, default_handle: 0, format_error: 1]

      def start do
        Feb.start unquote(module)
      end

      defp static_root, do: unquote(root_val)
    end
  end

  def start(_) do
    IO.puts "Executing Feb.start"
  end

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
    # Disable hygiene so that `_data` is accessible in the client code
    quote hygiene: false do
      def handle(:post, unquote(path), _data) do
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
      def handle(method, path, data) do
        if not (method in [:get, :post, :delete]) do
          format_error(400)
        elsif: not match?("/" <> _, path)
          format_error(400)
        else:
          format_error(404)
        end
      end
    end
  end

  ###

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
end
