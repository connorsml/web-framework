defmodule Feb do
  # This is what the call
  #
  #    use Feb, root: "assets"
  #
  # expands to.
  defmacro __using__(module, opts) do
    root_val = case Keyword.get(opts, :root, ".")

    quote do
      import Feb, only: [get: 2, post: 2]

      def start do
        Feb.start unquote(module)
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
        match: { :ok, data }
          { :ok, data }
        else:
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
