class AreaWatcher
	include Mongoid::Document
	include Mongoid::Timestamps
	belongs_to :area, index: true
	field :user_id, type: String
	field :first_coord_time_stamp, type: DateTime
	field :last_coord_time_stamp, type: DateTime
	field :finished, type: Boolean, default: false
	field :visit_type, type: String # "full_visit", "single_visit", "continued_visit"

	field :pre_selection_stage, type: Boolean, default: true
	field :pre_selection_count, type: Integer, default: 1
	index({user_id: 1})


  def self.add_location_data(current_user_id, coords, time_stamp)
    loc = UserLocation.new
    loc.user_id = current_user_id
    loc.coords = coords.split(",").map(&:to_f)
    loc.time_stamp = time_stamp.to_datetime
    loc.save
    loc
  end

  # # ---------- Create and update Area Watcher ----------- Begin
  def self.watch_area(coords, current_user_id)
    in_an_area = AreaWatcher.inside_an_area?(coords.coords)
    watchers = AreaWatcher.where(user_id: current_user_id)
    if watchers.any? #
      update_or_create_area_watcher(in_an_area, watchers, coords)
    elsif in_an_area.first == true
      # TODO update this, 
      new_area_watcher(current_user_id, in_an_area.last.id, coords.time_stamp, "full_visit")
    else
      return true
    end
  end

  def update_or_create_area_watcher(in_an_area, current_user_id, coords)
    last_watcher = watchers.order_by(created_at: :desc).first
    if !last_watcher.finished
      if last_watcher.pre_selection_stage == true
        update_pre_selected(last_watcher, coords)
      else
        inside_last_area_or_not(last_watcher, coords, in_an_area, current_user_id)
      end
    elsif in_an_area.first == true
      next_area_watcher_setup(last_watcher, coords, current_user_id, in_an_area )
    else
      return true
    end
  end

  def update_pre_selected(last_watcher, coords)
    if last_watcher.area.has_coords? coords
      if last_watcher.updated_at < 60.seconds.ago
        last_watcher.destroy
      else
        last_watcher.pre_selection_count += 1
        if last_watcher.pre_selection_count == 3
          last_watcher.pre_selection_stage = false
        end
        last_watcher.save
      end
    else
      last_watcher.destroy
    end
  end

  def inside_last_area_or_not(last_watcher, coords, in_an_area, current_user_id)
    if last_watcher.area.has_coords? coords
      update_last_watcher_in_area(last_watcher, in_an_area, coords, current_user_id)
    else
      locs = previous_user_coord(current_user_id, 0, 3)
      update_last_watcher_not_in_an_area(locs, last_watcher, in_an_area, coords, current_user_id)
    end
  end

  def update_last_watcher_in_area(last_watcher, in_an_area, coords, current_user_id)
    if last_watcher.updated_at < 90.seconds.ago
      make_watcher_a_visit(last_watcher, in_an_area, current_user_id, coords)
    else
      last_watcher.touch
    end
  end

  def update_last_watcher_not_in_an_area(locs, last_watcher, in_an_area, coords, current_user_id)
    if last_watcher.updated_at < 90.seconds.ago
      make_watcher_a_visit(last_watcher, in_an_area, current_user_id, coords)
    elsif !last_watcher.area.has_coords? locs
      complete_watcher(last_watcher, last_watcher.visit_type)
    else
      last_watcher.touch
    end
  end

  def make_watcher_a_visit(last_watcher, in_an_area, current_user_id, coords)
    # Doesn't seem right, Need to come back to this
    complete_watcher(last_watcher, 
      last_watcher.visit_type ==  "full_visit" ? "single_visit" : "continued_visit"
      )
    if in_an_area.first == true
      next_area_watcher_setup(last_watcher, coords, current_user_id, in_an_area )
    end
  end

  def complete_watcher(last_watcher, visit)
    last_watcher.update_attributes(
      last_coord_time_stamp: last_watcher.updated_at, 
      finished: true,
      visit_type: visit,
    )
  end

  def new_area_watcher(current_user_id, area_id, time_stamp, visit_type)
    a = AreaWatcher.new
    a.user_id = current_user_id
    a.area_id = area_id
    a.first_coord_time_stamp = time_stamp
    a.visit_type = visit_type
    a.save
  end

  def next_area_watcher_setup(last_watcher, coords, current_user_id, in_an_area )
    if is_a_continued_visit?(last_watcher, coords, in_an_area, current_user_id)
      new_area_watcher(current_user_id, in_an_area.last.id, coords.time_stamp, "continued_visit")
    elsif is_a_visit?(last_watcher, coords, in_an_area, current_user_id)
      new_area_watcher(current_user_id, in_an_area.last.id, coords.time_stamp, "single_visit")
    else
      new_area_watcher(current_user_id, in_an_area.last.id, coords.time_stamp, "full_visit")
    end
  end

  # 1) Check to see if the last area watcher was a single or continued visit
  # 2) Was the last area watcher updated in the last 4 hours
  # 3) Is the current area the user is in, the same as the previous area
  # 3) Does the current area have the users previous 2 coords
  def is_a_continued_visit?(last_watcher, coords, in_an_area, current_user_id)
    ["single_visit", "continued_visit"].include?(last_watcher.visit_type) &&
    last_watcher.last_coord_time_stamp > 4.hours.ago && 
    in_an_area.last.id == last_watcher.area_id && 
    in_an_area.last.has_coords?(previous_user_coord(current_user_id, 1, 2))
  end

  def is_a_visit?(last_watcher, coords, in_an_area, current_user_id)
    if last_watcher.visit_type == "continued_visit"
      last_watcher.last_coord_time_stamp > 6.hours.ago && 
      in_an_area.last.id == last_watcher.area_id && 
      in_an_area.last.has_coords?(previous_user_coord(current_user_id, 1, 2))
    elsif last_watcher.visit_type == "single_visit"
      last_watcher.last_coord_time_stamp > 12.hours.ago &&
      in_an_area.last.id == last_watcher.area_id && 
      in_an_area.last.has_coords?(previous_user_coord(current_user_id, 1, 2))
    else
      false
    end
  end

  def previous_user_coord(current_user_id, offset = 1, take = 1)
    UserLocation.where(user_id: current_user_id).order_by(time_stamp: :desc).offset(offset).limit(take).to_a
  end

  
  def self.inside_an_area?(coords)
   # coords = Mongoid::Geospatial::Point object
   if coords.is_a? Array
     area = Area.where(
       area_profile: {
         "$geoIntersects" => {
           "$geometry"=> {
             type: "Point",
             coordinates: [coords.first, coords.last]
           }
         }
       },
       :level.nin => ["L0"],
       :level.in => ["L1", "L2"]
       )
   else
     area = Area.where(
       area_profile: {
         "$geoIntersects" => {
           "$geometry"=> {
             type: "Point",
             coordinates: [coords.x, coords.y]
           }
         }
       },
       :level.nin => ["L0"],
       :level.in => ["L1", "L2"]
       )
   end
   # area = Area.where(title: "Arcadia on 49th")
   if area.any?
      if area.count > 1
        l1 = area.to_a.find {|a| a.level == 'L2'}
        return true, l1
      else
        return true, area.first     
      end
   else
     return false, ""
   end
  end
  # ---------- Create and update Area Watcher ----------- END
end