# e-Hotels Premium Seed Data Pack (A+ / Beyond-Scope Version)

This package is a richer, more presentation-ready synthetic dataset for the CSI2132 e-Hotels project.

## Core project-ready files
These align closely with a standard hotel-booking relational schema:
- hotel_chains.csv
- hotels.csv
- rooms.csv
- room_amenities.csv
- customers.csv
- employees.csv
- bookings.csv
- rentings.csv
- payments.csv

## Optional beyond-scope bonus files
Use these only if your schema supports them:
- loyalty_profiles_optional.csv
- archived_bookings_optional.csv
- archived_rentings_optional.csv
- maintenance_logs_optional.csv
- seasonal_rate_adjustments_optional.csv

## Scale
- Hotel chains: 5
- Hotels: 50
- Rooms: 600
- Customers: 325
- Employees: 450
- Bookings: 787
- Rentings: 626
- Payments: 626
- Archived bookings (bonus): 438
- Archived rentings (bonus): 419
- Maintenance logs (bonus): 101
- Seasonal rate rows (bonus): 600

## Why this version is stronger
1. More realistic city/area distribution across North America
2. Mixed hotel categories (3/4/5 stars) and differentiated pricing
3. Rich room types beyond the minimum project requirement
4. Occupancy-aware data generation to avoid overlapping bookings on the same room/date range
5. Booking-to-renting conversion paths and walk-in rentings
6. Payment variety with paid/partial cases
7. Optional archive snapshots for history preservation demos
8. Optional seasonal pricing and maintenance logs for advanced analytics/demo polish

## Suggested use
- Import the core files first.
- Keep the optional files for:
  - bonus analytics,
  - stronger presentation/video demos,
  - advanced views,
  - archived-history justification,
  - trigger demonstrations.

## Important
You may still need to rename columns to match your exact PostgreSQL schema.
