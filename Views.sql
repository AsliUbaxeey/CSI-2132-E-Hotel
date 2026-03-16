-- view 1: view of rooms avaialbe in an area
create view available_rooms_per_area as
select
    h.Area,
    count(r.Room_id) as available_rooms
from Hotel h
join Room r on h.Hotel_id = r.Hotel_id
where not exists (
    select 1
    from Booking b
    where b.Room_id = r.Room_id
      and CURRENT_DATE >= b.StartDate
      and CURRENT_DATE < b.EndDate
)
and not exists (
    select 1
    from Renting rt
    where rt.Room_id = r.Room_id
      and CURRENT_DATE >= rt.StartDate
      and CURRENT_DATE < rt.EndDate
)
group by h.Area;

-- view 2: Totalll capacity of rooms for each hotel
create view hotel_total_capacity as
select
    h.Hotel_id,
    h.HotelName,
    sum(r.Capacity) as total_capacity
from Hotel h
join Room r on h.Hotel_id = r.Hotel_id
group by h.Hotel_id, h.HotelName;