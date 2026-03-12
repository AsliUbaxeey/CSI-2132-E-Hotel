-- Trggers

----------------------------------------------------------------
-- Check if the assigned manager wors at the hotel it manages
CREATE OR REPLACE FUNCTION check_manager_works_at_same_hotel()
RETURNS TRIGGER AS $$
BEGIN
   
    IF NEW.Manager_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1
            FROM Employee e
            WHERE e.Person_id = NEW.Manager_id
              AND e.Hotel_id = NEW.Hotel_id
        )
		THEN
            RAISE EXCEPTION
                'Manager % must be an employee of hotel %',
                NEW.Manager_id, NEW.Hotel_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_manager_same_hotel
BEFORE INSERT OR UPDATE OF Manager_id, Hotel_id
ON Hotel
FOR EACH ROW
EXECUTE FUNCTION check_manager_works_at_same_hotel();
--------------------------------------------
-- prevent a booking to overlapp with a active renting
CREATE OR REPLACE FUNCTION booking_overlap_with_renting()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Renting r
        WHERE r.Room_id = NEW.Room_id
          AND daterange(r.StartDate, r.EndDate, '[)') && daterange(NEW.StartDate, NEW.EndDate, '[)')
    )
	THEN
        RAISE EXCEPTION
            'Booking for room % overlaps an active renting',
            NEW.Room_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_booking_no_overlap_with_renting
BEFORE INSERT OR UPDATE OF Room_id, StartDate, EndDate
ON Booking
FOR EACH ROW
EXECUTE FUNCTION booking_overlap_with_renting();
-------------------------------------------
-- Check if the renting matches the original booking or if it overlapps with another booking
CREATE OR REPLACE FUNCTION check_renting_creation()
RETURNS TRIGGER AS $$
DECLARE
    source_booking RECORD;
BEGIN
    -- If renting comes from a booking
    IF NEW.Booking_id IS NOT NULL THEN
        SELECT *
        INTO source_booking
        FROM Booking b
        WHERE b.Booking_id = NEW.Booking_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION
                'Referenced booking % does not exist',
                NEW.Booking_id;
        END IF;

        IF source_booking.Room_id <> NEW.Room_id THEN
            RAISE EXCEPTION
                'Renting room does not match the original booking';
        END IF;

        IF source_booking.Customer_id <> NEW.Customer_id THEN
            RAISE EXCEPTION
                'Renting customer must match the original booking customer';
        END IF;

        IF source_booking.StartDate <> NEW.StartDate
           OR source_booking.EndDate <> NEW.EndDate THEN
            RAISE EXCEPTION
                'Renting dates must match the original booking dates';
        END IF;
    END IF;

    -- Check if overlaps
    IF EXISTS (
        SELECT 1
        FROM Booking b
        WHERE b.Room_id = NEW.Room_id
          AND daterange(b.StartDate, b.EndDate, '[)') &&
              daterange(NEW.StartDate, NEW.EndDate, '[)')
          AND (NEW.Booking_id IS NULL OR b.Booking_id <> NEW.Booking_id)
    ) 
	THEN
        RAISE EXCEPTION
            'Renting for room % overlaps with an existing booking',
            NEW.Room_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_renting
BEFORE INSERT OR UPDATE OF Room_id, Customer_id, StartDate, EndDate, Booking_id
ON Renting
FOR EACH ROW
EXECUTE FUNCTION check_renting_creation();
---------------------------------------------
--Delete booking after conveted to renting
CREATE OR REPLACE FUNCTION delete_booking_after_renting()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Booking_id IS NOT NULL THEN
        DELETE FROM Booking
        WHERE Booking_id = NEW.Booking_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_booking_after_convert
AFTER INSERT ON Renting
FOR EACH ROW
EXECUTE FUNCTION delete_booking_after_renting();
--------------------------------------------
--archiving a booking when deleting
CREATE OR REPLACE FUNCTION archive_deleted_booking()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO BookingArchive (
        OriginalBooking_id,
        ArchivedDate,
        CustomerFullName,
        CustomerIDType,
        CustomerIDValue,
        CustomerAddress,
        RoomNumber,
        Capacity,
        RoomView,
        Extendable,
        PricePerNight,
        HotelChainName,
        HotelName,
        HotelAddress,
        StartDate,
        EndDate,
        BookingDate
    )
    SELECT
        OLD.Booking_id,
        CURRENT_TIMESTAMP,
        CONCAT_WS(' ', p.FirstName, p.MiddleName, p.LastName),
        c.IdType,
        c.IdValue,
        p.Address,
        r.RoomNumber::varchar,
        r.Capacity,
        r.RoomView,
        r.Extendable,
        r.PricePerNight,
        hc.ChainName,
        h.HotelName,
        h.Address,
        OLD.StartDate,
        OLD.EndDate,
        OLD.BookingDate
    FROM Customer c
    JOIN Person p ON p.Person_id = c.Person_id
    JOIN Room r ON r.Room_id = OLD.Room_id
    JOIN Hotel h ON h.Hotel_id = r.Hotel_id
    JOIN HotelChain hc ON hc.Chain_id = h.Chain_id
    WHERE c.Person_id = OLD.Customer_id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER archive_booking_before_delete
BEFORE DELETE ON Booking
FOR EACH ROW
EXECUTE FUNCTION archive_deleted_booking();

--------------------------------------------------
-- archiving a renting when deleted
CREATE OR REPLACE FUNCTION archive_deleted_renting()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO RentingArchive (
        OriginalRentingID,
        ArchivedAt,
        CustomerFullName,
        CustomerIDType,
        CustomerIDValue,
        CustomerAddress,
        EmployeeID,
        EmployeeFullName,
        RoomNumber,
        Capacity,
        RoomView,
        Extendable,
        PricePerNight,
        HotelChainName,
        HotelName,
        HotelAddress,
        StartDate,
        EndDate,
        RentingDate
    )
    SELECT
        OLD.Renting_id,
        CURRENT_TIMESTAMP,
        CONCAT_WS(' ', cp.FirstName, cp.MiddleName, cp.LastName),
        c.IdType,
        c.IdValue,
        cp.Address,
        e.Person_id,
        CONCAT_WS(' ', ep.FirstName, ep.MiddleName, ep.LastName),
        r.RoomNumber::varchar,
        r.Capacity,
        r.RoomView,
        r.Extendable,
        r.PricePerNight,
        hc.ChainName,
        h.HotelName,
        h.Address,
        OLD.StartDate,
        OLD.EndDate,
        OLD.RentingDate
    FROM Customer c
    JOIN Person cp ON cp.Person_id = c.Person_id
    JOIN Employee e ON e.Person_id = OLD.Employee_id
    JOIN Person ep ON ep.Person_id = e.Person_id
    JOIN Room r ON r.Room_id = OLD.Room_id
    JOIN Hotel h ON h.Hotel_id = r.Hotel_id
    JOIN HotelChain hc ON hc.Chain_id = h.Chain_id
    WHERE c.Person_id = OLD.Customer_id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER archive_renting_before_delete
BEFORE DELETE ON Renting
FOR EACH ROW
EXECUTE FUNCTION archive_deleted_renting();
