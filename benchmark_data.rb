require 'benchmark'

def run_benchmark
  users = User.all

  hash_1 = HashWithIndifferentAccess.new
  hash_2 = HashWithIndifferentAccess.new

  puts "================================"
  puts "ActiveModel Serializer Benchmark"
  puts Benchmark.measure {
    hash_1 = ActiveModel::SerializableResource.new(users, each_serializer: UserSerializer).as_json
  }
  puts "================================"

  puts "================================"
  puts "JSONApi Serializer Benchmark"
  puts Benchmark.measure {
    hash_2 = JsonApi::UserSerializer.new(users).as_json
  }
  puts "================================"
end
run_benchmark

# Benchmark Results
# ================================
# ActiveModel Serializer Benchmark      
#   0.134760   0.000093   0.134853 (  0.137027)
# ================================      
# ================================      
# JSONApi Serializer Benchmark          
#   0.022771   0.000041   0.022812 (  0.022845)
# ================================      
