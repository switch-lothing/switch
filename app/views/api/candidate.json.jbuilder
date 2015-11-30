json.array!(@candidate) do |candidate|
  json.nickname candidate.nickname
  json.phone_number candidate.phone_number
end