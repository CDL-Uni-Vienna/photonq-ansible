import csv
import requests

url = "http://10.88.0.1:3050/graphql"

with open("cdl_rest_api_userprofile.csv", newline="") as csvfile:
    spamreader = csv.reader(csvfile, delimiter=",", quotechar="|")
    for row in spamreader:
        try:
            test = row[5].split(" ")[1]

            if row[4].split("@")[1] != "gmail.com":
                print(row[4])
            print(
                f"uuid: {row[3]}\nemail: {row[4]}\npassword: {row[0]}\nfirstName: {row[5].split(' ')[0]}\nlastName: {row[5].split(' ')[1]}"
            )
        except:
            print(row[4])
            pass

        body1 = f"""
        mutation {{
            usersAdd(fnArgs: {{userId: "{row[3]}" email: "{row[4]}", password: "{row[0]}"}})
        }}
        """

        response1 = requests.post(url=url, json={"query": body1})
        print("response status code: ", response1.status_code)
        if response1.status_code == 200:
            print("response : ", response1.content)

        try:
            body2 = f"""
            mutation {{
                usersUpdate(fnArgs: {{userId: "{row[3]}", firstName: "{row[5].split(' ')[0]}", lastName: "{row[5].split(' ')[1]}", isActive: "true"}})
            }}
            """
            response2 = requests.post(url=url, json={"query": body2})
            print("response status code: ", response2.status_code)
            if response2.status_code == 200:
                print("response : ", response2.content)
        except:
            print(row[4])
            pass
