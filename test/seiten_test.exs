defmodule SeitenTest do
  use ExUnit.Case

  defmodule Users do
    use Seiten
  end

  def in_list do
    1..25 |> Enum.to_list
  end

  def as_struct do
    Users.paginate(in_list, 1)
  end

  test "page range function" do
    assert Seiten.pages_range(in_list) == 1..3
    assert Seiten.pages_range(as_struct) == 1..3
  end

  test "paginate resources" do
    %{resources: resources} = Users.paginate(in_list, 2)
    assert resources == 11..20 |> Enum.to_list
  end

  test "paginate resources with current page from params" do
    paged = Users.paginate(in_list, Plug.Conn.fetch_params(%Plug.Conn{}))
    assert %{resources: [1,2,3,4,5,6,7,8,9,10]} = paged
    %{page: 1} = paged

    paged = Users.paginate(in_list, %Plug.Conn{params: %{"users_page" => "2"}})
    assert %{resources: [11,12,13,14,15,16,17,18,19,20]} = paged
    %{page: 2} = paged
  end
end
