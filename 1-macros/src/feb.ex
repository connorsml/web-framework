defmodule Feb do
  # This is what the call
  #
  #    use Feb, root: "assets"
  #
  # expands to.
  defmacro __using__(opts) do
    root_val = Keyword.get(opts, :root, ".")

    quote do
      import Feb, only: [get: 2, post: 2]

      def start do
        Feb.start unquote(__CALLER__.module)
      end

      defp static_root, do: unquote(root_val)
    end
  end

  def start(_) do
    IO.puts "Executing Feb.start"
  end

  # GET request handler. It has two forms.
  defmacro get(path, [do: code]) do
    quote do
      def handle(:get, unquote(path), _data) do
        unquote(code)
      end
    end
  end

  defmacro get(path, [file: bin]) when is_binary(bin) do
    quote do
      def handle(:get, unquote(path), _data) do
        full_path = File.join([static_root(), unquote(bin)])
        case File.read(full_path) do
          { :ok, data } ->
            { :ok, data }
          _ ->
            { :error, "404 Not Found" }
        end
      end
    end
  end

  # A POST request handler
  defmacro post(path, [do: code]) do
    # Disable hygiene so that `_data` is accessible in the client code
    quote hygiene: false do
      def handle(:post, unquote(path), _data) do
        unquote(code)
      end
    end
  end
end
