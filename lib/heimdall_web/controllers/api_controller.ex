defmodule HeimdallWeb.ApiController do
  use HeimdallWeb, :controller
  import Plug.Conn


  # this route takes one upc, and returns the upc with the check digit added
  # http://0.0.0.0:4000/api/add_check_digit/1234
  def add_check_digit(conn, params) do
    check_digit_with_upc = _calculate_check_digit(params["upc"])
    _send_json(conn, 200, check_digit_with_upc)
  end

  # this route takes a comma separated list and should add a check digit to each element
  # http://0.0.0.0:4000/api/add_a_bunch_of_check_digits/12345,233454,34341432
  def add_a_bunch_of_check_digits(conn, params) do
    upcs = String.split(params["upcs"], ",")
    check_digits_with_upc = Enum.map(upcs, fn upc -> _calculate_check_digit(upc) end)
    _send_json(conn, 200, check_digits_with_upc)
  end

  # these are private methods
  defp _calculate_check_digit(upc) do
    if String.length(upc) != 11, do: raise "UPC must be 11 characters, was: " <> upc
    upc_num = elem(Integer.parse(upc, 10), 0)
    numbered = Enum.zip(Integer.digits(upc_num, 10), 1..11)
    odds = for {v, n} <- numbered, rem(n,2) == 1, do: v
    evens = for {v, n} <- numbered, rem(n,2) == 0, do: v
    check = 10 - rem(Enum.sum(odds)*3 + Enum.sum(evens), 10)
    upc <> Integer.to_string(check)
  end

  # this is a thing to format your responses and return json to the client
  defp _send_json(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Poison.encode!(body))
  end

end
