defmodule VercheckEx do
  # requireで使用するライブラリを指定
  require HTTPoison
  require Floki
  require Timex
  use Timex

  def fetch_content(url, type) do
    ret = HTTPoison.get!( url ) # urlで指定されるページのデータを取得
    %HTTPoison.Response{status_code: 200, body: body} = ret
    # HTML bodyを取得する
    # HTMLパーザー Flokiで処理
    # 名前、リリース日時を取得
    {_,_,n} =
      body
      |> Floki.find("[itemprop=title]")
      |> List.first
    {_, date} =
      body
      |> Floki.find("time")
      |> Floki.attribute("datetime")
      |> List.first
      |> Timex.DateFormat.parse("{ISOz}")

    # IO.puts body
    # IO.puts Floki.find(body, "span.tag-name")
    IO.puts type

    {_,_,x} =
      if (type == :type1) do # バージョン番号を取得
          body
          |> Floki.find("span.tag-name")
          |> List.first
      else
          body
          |> Floki.find("span.css-truncate-target")
          |> List.first
      end
    #UTC時刻をJSTに変更
    date |> Timex.Date.Convert.to_erlang_datetime
         |> Timex.Date.from("Asia/Tokyo")
    {hd(n),hd(x),date} # 戻り値はタプル
  end

  def put_a_formatted_line(val) do # 1行出力
    {title, ver, date} = val
    l = title
    if String.length(title) < 8 do
      l = l <> "\t"
    end
    l = l <> "\t" <> ver
    if String.length(ver) < 8 do
      l = l <> "\t"
    end
    l = l <> "\t" <> Timex.DateFormat.format!(date, "%Y.%m.%d", :strftime)
    now = Timex.Date.now("JST")
    diff =  Timex.Date.diff( date, now, :days) # リリースから今日までの日数
    if diff < 14 do # 14日以内なら警告する。以前の仕事が2週間スプリントだった名残り。
      l = l <> "\t<<<<< updated at " <> Integer.to_string(diff) <> " day(s) ago."
    end
    IO.puts(l)
  end
end

urls = [
  {"https://github.com/jquery/jquery/releases", :type1},
  {"https://github.com/angular/angular/releases", :type1},
  {"https://github.com/facebook/react/releases", :type2},
  {"https://github.com/PuerkitoBio/goquery/releases", :type1},
  {"https://github.com/revel/revel/releases", :type2},
  {"https://github.com/lhorie/mithril.js/releases", :type1},
  {"https://github.com/riot/riot/releases", :type1},
  {"https://github.com/atom/atom/releases", :type2},
  {"https://github.com/Microsoft/TypeScript/releases", :type2},
  {"https://github.com/docker/docker/releases", :type1},
  {"https://github.com/JuliaLang/julia/releases", :type2},
  {"https://github.com/nim-lang/Nim/releases", :type1},
  {"https://github.com/elixir-lang/elixir/releases", :type2},
  {"https://github.com/philss/floki/releases", :type1},
  {"https://github.com/takscape/elixir-array/releases", :type2},
]

# 逐次呼出し→結果出力                                                                                                                                         HTTPoison.start
Enum.each(urls, fn(i) ->
  {u,t} = i
  res  = VercheckEx.fetch_content(u,t)
  VercheckEx.put_a_formatted_line res
end)
