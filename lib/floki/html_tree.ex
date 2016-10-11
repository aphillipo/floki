defmodule Floki.HTMLTree do
  defstruct tree: %{}, root_id: ""

  alias Floki.{HTMLNode, HTMLTree, TextNode}

  defmodule Stack do
    defstruct parent_node: nil, children: []
  end

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

    parse_tree(tree, children, root_node, [], ids_seeder)
  end

  defp parse_tree(tree, [], _, [], _), do: tree
  defp parse_tree(tree, [text | children], parent_node, stack, ids_seeder) when is_binary(text) do
    parent_id = parent_node.floki_id
    previous = tree.tree
    new_id = ids_seeder.seed()
    new_node = %TextNode{content: text,
                         floki_id: new_id,
                         floki_parent_id: parent_id}

    children_ids = parent_node.children_ids
    updated_parent = %{parent_node | children_ids: [new_id | children_ids]}

    newer =
      previous
      |> Map.put(new_id, new_node)
      |> Map.put(parent_id, updated_parent)

    parse_tree(%{tree | tree: newer}, children, updated_parent, stack, ids_seeder)
  end
  defp parse_tree(tree, [{tag, attrs, child_children} | children], parent_node, stack, ids_seeder) do
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

    s_item = %Stack{parent_node: new_node, children: child_children}

    parse_tree(%{tree | tree: newer}, children, updated_parent, [s_item|stack], ids_seeder)
  end
  defp parse_tree(tree, [], _, [stack_h|stack], ids_seeder) do
    parse_tree(tree, stack_h.children, stack_h.parent_node, stack, ids_seeder)
  end
end
