#json.extract! @paged, :id, :title, :creator, :type, :created_at, :updated_at
json.extract! @paged, :id, :title, :creator, :type, :parent, :prev_sib, :next_sib
