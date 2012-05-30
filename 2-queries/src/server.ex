defmodule HelloServer do
  use Feb, root: "assets"

  get "/" do
    { :ok, "Hello world!" }
  end

  get "/demo", file: "demo.html"

  post "/" do
    { :ok, "You're posted!\nYour data: #{inspect _data}" }
  end

  ## New stuff below this line ##

  multi_handle "/kvstore" do
    :post ->
      IO.puts "Got a POST request with data: #{inspect _data}"
      :ok

    :get ->
      IO.puts "Got a GET request with query: #{inspect _query}"
      :ok
  end

  get "/search", query do
    search = Dict.get query, "q"
    if search do
      { :ok, "No items found for the query '#{search}'" }
    else
      { :ok, "No query" }
    end
  end
end
