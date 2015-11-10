defmodule Wiki.PageView do
  use Wiki.Web, :view
  alias Wiki.Page
  alias Wiki.Repo

  def process_content(page) do
    process_content_string(page.content)
  end
  def process_content_string(content) do
    title_to_page = extract_pages(content)
    poss = find_link_positions content
    to_tokens(poss, content, title_to_page)
  end

  def extract_pages(content) do
    Regex.scan(~r/\[\[(.+?)]]/, content)       # [[title]]部分を抽出
    |> Enum.map(fn [_|title] -> hd(title) end) # 複数のtitleを集める
    |> select_pages_from_titles                # titleがマッチするPageを全件取得
    |> list_to_map
  end

  defp list_to_map(pages) do
    list_to_map(Map.new(), pages)
  end

  defp list_to_map(map,[]) do
    map
  end

  defp list_to_map(map,[page|pages]) do
    Map.put(map, page.title, page)
    |> Map.merge(list_to_map(map, pages))
  end

  def select_pages_from_titles(titles) do
    # ここの書き方は以下のページで知った
    # http://qiita.com/HirofumiTamori/items/b71ca312778e42326017#すべての投稿を選択
    Page
    |> Page.by_titles(titles)
    |> Repo.all
  end

  def find_link_positions(content) do
    Regex.scan(~r/\[\[(.+?)]]/, content, return: :index)
    # 戻り値は以下のような形式のList
    # [ [{マッチ全体の開始インデックス,マッチ全体の終了インデックス}, {グループの開始インデックス,グループの終了インデックス}] ]
  end

  defp to_tokens(positions, content, title_to_page) do
    to_tokens([], positions, content, title_to_page, 0)
  end
  defp to_tokens(tokens, [], content, _title_to_page, start_position) do
    tokens++[binary_part(content, start_position, byte_size(content) - start_position)]
  end

  defp to_tokens(tokens, [first_position|remind], content, title_to_page, start_position) do
    # Regex.scan(pattern,str,return: :index)が返す位置はバイト位置であり文字位置ではない.
    # このため部分文字列を得るにはString.sliceではなくてbinary_partを使う必要がある.
    first_token  = binary_part content, start_position, link_start_position(first_position)-start_position
    link_title   = extract_title content, first_position
    second_token = case Map.get(title_to_page, link_title) do
                     nil  -> render Wiki.SharedView, "page_new.html", title: link_title
                     page -> render Wiki.SharedView, "page_link.html", %{ id: page.id, title: page.title }
                   end
    to_tokens tokens++[first_token, second_token], remind, content, title_to_page, link_start_position(first_position)+link_length(first_position)
  end

  defp link_start_position(pos) do
    elem(hd(pos), 0)
  end
  defp link_length(pos) do
    elem(hd(pos), 1)
  end
  defp title_start_position(pos) do
    elem(hd(tl(pos)), 0)
  end
  defp title_length(pos) do
    elem(hd(tl(pos)), 1)
  end
  def extract_title(content, pos) do
    binary_part content, title_start_position(pos), title_length(pos)
  end
end
