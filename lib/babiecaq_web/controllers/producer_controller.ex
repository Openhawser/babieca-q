defmodule BabiecaqWeb.ProducerController do
  use BabiecaqWeb, :controller

  def create(conn, %{"topic" => topic_name, "msg" => msg}) do
    IO.puts(inspect(%{"topic" => topic_name, "msg" => msg}))
    Plug.Conn.send_resp(conn, 201, "")
  end
  def create(conn, _) do
    Plug.Conn.send_resp(conn, 400, "Bad format, keys are topic and msg")
  end

end
