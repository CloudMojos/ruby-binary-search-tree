# Node for a binary tree / doubly linked list
class Node
  attr_accessor :left, :right, :data

  def initialize(data)
    @data = data
    @left = nil
    @right = nil
  end
end

# Binary Search Tree
class Tree
  attr_accessor :root, :array

  def initialize(array)
    @array = array.sort.uniq
    @root = build_tree(@array)
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right

    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"

    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end

  # return node if found, nil if not
  def find(value, root = @root)
    return root if root.nil? || root.data == value

    return find(value, root.left) if value < root.data

    return find(value, root.right) if value > root.data
  end

  # return inserted node, nil if duplicate
  def insert(value, root = @root)
    return Node.new(value) unless root

    root.left = insert(value, root.left) if value < root.data

    root.right = insert(value, root.right) if value > root.data

    root
  end

  # return new tree without deleted node
  def delete(value, root = @root)
    return nil unless root

    root.left = delete(value, root.left) if value < root.data

    root.right = delete(value, root.right) if value > root.data

    if root.data == value
      return nil if root.left.nil? && root.right.nil?

      return root = root.right if root.left.nil?

      return root = root.left if root.right.nil?

      root.data = next_biggest(root.right).data
      root.right = delete(root.data, root.right)
    end
    root
  end

  # ITERATIVE v.
  # def level_order
  #   queue = [@root]
  #   result = []
  #   until queue.empty?
  #     result << root = queue.shift
  #     yield(root) if block_given?
  #     queue.push(root.left) if root.left
  #     queue.push(root.right) if root.right
  #   end
  #   result
  # end

  # I think I can optimize this by removing result = [] as a parameter, but I will move on for now
  # return array if no block was given
  def level_order(result = [], queue = [@root], &block)
    return if queue.empty?

    root = queue.shift
    yield(root) if block_given?
    queue.push(root.left) if root.left
    queue.push(root.right) if root.right
    level_order(result << root, queue, &block)
    result unless block_given?
  end

  # return array if no block was given
  def pre_order(result = [], root = @root, &block)
    return if root.nil?

    result << root
    yield(root) if block_given?
    pre_order(result, root.left, &block)
    pre_order(result, root.right, &block)
    result unless block_given?
  end

  # return array if no block was given
  def in_order(result = [], root = @root, &block)
    return if root.nil?

    result << root
    in_order(result, root.left, &block)
    yield(root) if block_given?
    in_order(result, root.right, &block)
    result unless block_given?
  end

  # return array if no block was given
  def post_order(result = [], root = @root, &block)
    return if root.nil?

    result << root
    post_order(result, root.left, &block)
    post_order(result, root.right, &block)
    yield(root) if block_given?
    result unless block_given?
  end

  # return the number of edges of the longest path in the tree
  def height(root = @root)
    return 0 if root.nil?
    return 1 if root.right.nil? && root.left.nil?

    height(root.left) > height(root.right) ? height(root.left) + 1 : height(root.right) + 1
  end

  # return the number of edges from root to node
  def depth(node, root = @root)
    return 1 if root == node

    return depth(node, root.left) + 1 if node.data < root.data
    return depth(node, root.right) + 1 if node.data > root.data
  end

  # return true if difference of the height of left and right is less than or equal to one
  def balanced?
    (height(@root.left) - height(@root.right)).abs <= 1
  end

  # assign new balanced tree to @root
  def rebalance
    new_arr = self.in_order
    @root = build_tree(new_arr)
  end

  private

  # used in #remove, return node
  def next_biggest(root)
    return root unless root.left

    next_biggest(root.left)
  end

  # used in #initialize and #rebalance, return node tree
  def build_tree(array)
    return nil if array.empty?

    mid = array.length / 2 # if length = 1, 1 / 2 is 0.5 => 0

    root = Node.new(array[mid])
    root.left = build_tree(array[0...mid])
    root.right = build_tree(array[mid + 1..])

    root
  end
end

# DRIVER

# Initialize the tree
my_arr = Array.new(15) { rand(1..100) }
my_tree = Tree.new(my_arr)
my_tree.pretty_print
# eg.
# │       ┌── 100
# │       │   └── 84
# │   ┌── 78
# │   │   │   ┌── 72
# │   │   └── 66
# │   │       └── 64
# └── 58
#     │       ┌── 54
#     │   ┌── 50
#     │   │   └── 39
#     └── 32
#         │   ┌── 15
#         └── 10
#             └── 9
puts
puts my_tree.balanced?

# Add additional nodes (will return unbalanced most of the time)
my_add_arr = Array.new(100) { rand(50..55) }
my_add_arr.each do |e|
  my_tree.insert(e)
end
my_tree.pretty_print
# eg.
# │       ┌── 100
# │       │   └── 84
# │   ┌── 78
# │   │   │   ┌── 72
# │   │   └── 66
# │   │       └── 64
# └── 58
#     │           ┌── 55
#     │       ┌── 54
#     │       │   └── 53
#     │       │       │   ┌── 52
#     │       │       └── 51
#     │   ┌── 50
#     │   │   └── 39
#     └── 32
#         │   ┌── 15
#         └── 10
#             └── 9
puts
puts "Is the tree balanced? #{my_tree.balanced? ? 'Yes' : 'No'}"

# Print out in different orders
arr = []
puts
puts 'Level Order:'
my_tree.level_order { |n| arr << n.data }
p arr # eg. [58, 32, 78, 10, 50, 66, 100, 9, 15, 39, 54, 64, 72, 84, 53, 55, 51, 52]
arr = []
puts
puts 'Pre Order:'
my_tree.pre_order { |n| arr << n.data }
p arr # eg. [58, 32, 10, 9, 15, 50, 39, 54, 53, 51, 52, 55, 78, 66, 64, 72, 100, 84]
arr = []
puts
puts 'In Order:'
my_tree.in_order { |n| arr << n.data }
p arr # eg. [9, 10, 15, 32, 39, 50, 51, 52, 53, 54, 55, 58, 64, 66, 72, 78, 84, 100]
arr = []
puts
puts 'Post Order:'
my_tree.post_order { |n| arr << n.data }
p arr # eg. [9, 15, 10, 39, 52, 51, 53, 55, 54, 50, 32, 64, 72, 66, 84, 100, 78, 58]
