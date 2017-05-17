class TestFlow < OpenStruct
  def transitions(additive)
    additive ? additions : substractions
  end
end
