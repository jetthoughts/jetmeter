class TestFlow < OpenStruct
  def transitions(additive)
    Array(additive ? additions : substractions)
  end
end
