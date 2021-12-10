import datetime

import random
import pandas as pd


def de_identified():
    data = pd.read_csv("cost_90K_sample.csv")
    data["birthdate"] = pd.to_datetime(data["birthdate"], format='%Y-%m-%d')
    data["date"] = pd.to_datetime(data["date"], format='%Y-%m-%d')
    grp_by_member = data.groupby("member_id")
    
    de_identified_data = pd.DataFrame()
    for member, member_data in grp_by_member:
        member_data['date'] = member_data['date'] + datetime.timedelta(days=random.randint(10, 100))
        member_data['birthdate'] = member_data['birthdate'] + datetime.timedelta(days=random.randint(10, 100))
        member_data['member_id'] = member_data['member_id'] - random.randint(23, 3323)
        de_identified_data = de_identified_data.append(member_data, ignore_index=True)

    de_identified_data.to_csv("shuffled_cost_90k_sample.csv", index=False)


if __name__ == '__main__':
    de_identified()
