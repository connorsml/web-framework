defmodule HelloServer do
  use Feb, root: "assets"

  get "/" do
    { :ok, "Hello world!" }
  end

  get "/demo", file: "demo.html"

  post "/" do
    { :ok, "You're posted!\nYour data: #{inspect _data}" }
  end
end
