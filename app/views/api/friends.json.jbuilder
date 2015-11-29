json.array!(@friends) do |friend|
  json.nickname friend.nickname
  json.phone_number friend.phone_number
  json.switch friend.switch_status
  json.location_x friend.location_x
  json.location_y friend.location_y
end