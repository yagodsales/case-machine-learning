import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
import joblib

# Carrega dados
df = pd.read_csv(
    "http://raw.githubusercontent.com/datasciencedojo/datasets/master/titanic.csv"
)

# Preparo
target = "Survived"
ignore_cols = ["Name", "PassengerId", "Ticket", "Cabin"]
numeric = list(set(df._get_numeric_data().columns) - set([target] + ignore_cols))
categorical = list(set(df.columns) - set([target] + ignore_cols + numeric))
df_prep = pd.concat([
    df[numeric],
    df[[target]],
    pd.get_dummies(df[categorical], drop_first=True)
], axis=1).fillna(0)

# Split
X = df_prep.drop(columns=[target])
y = df_prep[target]
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Treino
rf = RandomForestClassifier(
    n_estimators=100,
    max_depth=5,
    oob_score=True,
    random_state=42
)
rf.fit(X_train, y_train)

# Validação rápida (opcional)
from sklearn.metrics import roc_auc_score
print("ROC AUC on test:", roc_auc_score(y_test, rf.predict(X_test)))

# Serializa
joblib.dump(rf, "model.pkl")
