# Firestore data model

users/{uid}/expenses/{expenseId}
  title (string), amountKobo (int), category (string),
  date (Timestamp), createdAt (Timestamp)

users/{uid}/budgets/{category}
  monthlyLimitKobo (int)

Access
- A user can read and write only their own users/{uid}/** documents.
- amountKobo and monthlyLimitKobo must be positive integers.
- category must be one of: food, transport, data, bills, fun, other.