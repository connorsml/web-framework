defmodule HelloServer do
  use Feb, root: "assets"

  get "/", query do
    search = Dict.get query, "search"
    if search do
      { :ok, "No items found for the query '#{search}'" }
    else:
      { :ok, "Hello world!" }
    end
  end

  get "/idontcare" do
    :ok
  end

  get "/demo", file: "demo.html"

  post "/" do
    { :ok, "You're posted!\nYour data: #{inspect _body}" }
  end

  ###

  #  handle "/kvstore", query, body do
  #  post:
  #    Enum.each query, fn({k, v}) ->
  #      Erlang.ets.insert :simple_table, {k, v}
  #    end
  #    :ok
  #
  #  get:
  #    key = Dict.get query, "key"
  #    if key do
  #      [val] = Erlang.ets.lookup :simple_table, key
  #      { :ok, val }
  #    else:
  #      { :error, 404 }
  #    end
  #
  #  delete:
  #    key = Dict.get query, "key"
  #    if key do
  #      Erlang.ets.delete :simple_table, key
  #      :ok
  #    else:
  #      { :error, 404 }
  #    end
  #  end

  default_handle

end
