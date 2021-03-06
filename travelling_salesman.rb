INFINITY = +1.0/0.0

require 'set'

class TravellingSalesman
  def initialize(graph)
    @graph = graph
  end

  def brute_force
    # always use 0 as home node
    nodes = (1..(@graph.size-1)).to_a

    min = INFINITY

    # try every permutation
    nodes.permutation.each do |perm|
      path = [0] + perm + [0] # set 0 as home and end
      weight = @graph.path_weight(path)

      if weight < min
        min = weight
      end
    end
    min
  end

  # turn an array into a binary representation
  def arr_to_b(array)
    array.reduce(0) { |a,x| a | 2**(x-1) }
  end

  # binary set to array
  def b_to_arr(num)
    num.to_s(2).chars.reverse.each_with_index.map do |x, pos|
      x == "1" ? pos + 1 : 0
    end
  end

  def dp
    costs = Hash.new
    n = @graph.size

    # initialize costs for 0 to all others
    (1..n-1).each do |k|
      costs[k] = Hash.new
      costs[k][arr_to_b([k])] = @graph.get(0, k)
    end

    # for every subset size from 2 to n-1
    (2..n-1).each do |s|
      # for every subset of {1..n-1}
      (1..n-1).to_a.combination(s) do |subset|
        # for every k in subset
        subset.each do |k|
          bin_subset = arr_to_b(subset)

          subset_sans_k = subset.reject{|x| x == k}
          bin_ssk = arr_to_b(subset_sans_k)

          # find minimum distance subset + distance to k
          costs[k][bin_subset] = subset_sans_k.map do |m|
            costs[m][bin_ssk] + @graph.get(m, k)
          end.min
        end
      end
    end

    bin_full_tour = arr_to_b(1..n-1)
    # find minimum distance for full tour
    (1..n-1).to_a.map do |k|
      costs[k][bin_full_tour] + @graph.get(0, k)
    end.min
  end

  def greedy
    n = @graph.size

    total = 0
    unvisited = (1..n-1).to_a.to_set

    from = 0

    while unvisited.length > 0
      min = INFINITY
      minnode = nil

      # find nearest neighbor
      unvisited.each do |to|
        dist = @graph.get(from, to)
        if dist < min
          min = dist
          minnode = to
        end
      end

      # add distance
      from = minnode
      unvisited.delete(from)
      total += min
    end
    
    total + @graph.get(from, 0)
  end
end
