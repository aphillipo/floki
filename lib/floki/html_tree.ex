defmodule Floki.HTMLTree do
  defstruct tree: %{}, root_id: ""

  alias Floki.{HTMLNode, HTMLTree}

  def parse(html_tree_as_tuple, ids_seeder) do
    root_id = ids_seeder.seed()

    {tag, attrs, children} = html_tree_as_tuple

    root_node = %HTMLNode{type: tag, attributes: attrs, floki_id: root_id}
    tree = %HTMLTree{
      root_id: root_id,
      tree: %{
        root_id => root_node
      }
    }

    parse_tree(tree, children, root_node, ids_seeder)
  end

  defp parse_tree(tree, [], _, _), do: tree
  defp parse_tree(tree, [{tag, attrs, _} | children], parent_node, ids_seeder) do
    parent_id = parent_node.floki_id
    previous = tree.tree
    new_id = ids_seeder.seed()
    new_node = %HTMLNode{type: tag,
                         attributes: attrs,
                         floki_id: new_id,
                         floki_parent_id: parent_id}

    children_ids = parent_node.children_ids
    updated_parent = %{parent_node | children_ids: [new_id | children_ids]}

    newer =
      previous
      |> Map.put(new_id, new_node)
      |> Map.put(parent_id, updated_parent)

    parse_tree(%{tree | tree: newer}, children, updated_parent, ids_seeder)
  end
end
