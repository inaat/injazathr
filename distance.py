import math

def haversine(lat1, lon1, lat2, lon2):
    R = 6371  # Earth's radius in kilometers

    # Convert latitude and longitude from degrees to radians
    lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])

    # Differences in coordinates
    dlat = lat2 - lat1
    dlon = lon2 - lon1

    # Haversine formula
    a = math.sin(dlat / 2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    # Distance in kilometers
    distance = R * c
    return distance

# Coordinates
lat1, lon1 = 34.9314499, 72.4712785
lat2, lon2 = 34.9314, 72.4700

# Calculate distance
distance = haversine(lat1, lon1, lat2, lon2)
print(f"The distance between the two points is {distance:.2f} kilometers.")
