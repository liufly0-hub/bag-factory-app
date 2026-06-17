import os

base = r"C:\Users\Wlos\.openclaw\workspace\projects\bag-factory-app"
dirs = [
    "supabase/migrations",
    "lib/core/config",
    "lib/core/constants",
    "lib/core/utils",
    "lib/models",
    "lib/repositories",
    "lib/services",
    "lib/providers",
    "lib/screens/auth",
    "lib/screens/worker",
    "lib/screens/boss",
    "lib/widgets",
    "lib/router",
    "android",
    "ios",
    "test/services",
    "test/widgets",
]
for d in dirs:
    os.makedirs(os.path.join(base, d), exist_ok=True)
print("All directories created")
