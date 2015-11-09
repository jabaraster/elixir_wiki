defmodule Wiki.PageView do
  use Wiki.Web, :view

  def process_content(conn, page) do
    # ループの中でDBアクセスするなんて超遅い実装だが、とりあえず機能の完成を優先する.
    Regex.replace(~r/\[\[(.+?)]]/, page.content, fn (_, title) ->
      case Wiki.Repo.get_by(Wiki.Page, title: title) do
        # 以下の手法はNG. HTMLになった時にタグ(など)がエスケープされる.
        nil -> render_to_string Wiki.SharedView, "page_new.html", %{ title: "hoge" }
        page -> render_to_string Wiki.SharedView, "page_link.html", %{ id: page.id, title: title }
      end
    end)
  end
end
