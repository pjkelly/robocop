guard 'rspec', :cli => '--colour --format Fuubar --drb', :all_on_start => false, :all_after_pass => false do
  watch('spec/spec_helper.rb')                       { "spec" }
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
end