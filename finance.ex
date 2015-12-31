defmodule Finance do
  require HTTPoison
  require Floki


  def fetch_fx do
    fx_url = "http://info.finance.yahoo.co.jp/fx/detail/?code=USDJPY=FX"
    ret = HTTPoison.get!(fx_url)
    %HTTPoison.Response{status_code: 200, body: body} = ret

    jpy = body
          |> Floki.find("#USDJPY_detail_bid")
          |> List.first
          |> elem(2)

    IO.inspect jpy
    [f, m, l] = jpy
    IO.puts f
    IO.puts List.first(elem(m, 2))
    IO.puts l
    IO.puts f <> List.first(elem(m, 2)) <> l
  end


end

Finance.fetch_fx
