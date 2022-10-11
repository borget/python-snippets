from head.shipments.models import Stop
data = [('545380','875193TN002'),
        ('545381','XD16')]

def update_stop_facility_ref():
    updated = 0
    for stop_id, ref in data:
        stop = Stop.objects.get(id=stop_id)
        # if stop.facility_ref:
        #     print(f"stop {stop_id} already has facility ref: {stop.facility_ref}, we would change to {ref}")
        #     continue
        stop.facility_ref = ref
        stop.save(update_fields=["facility_ref", "updated"])
        updated += 1
    print(f"{updated} stops updated")
