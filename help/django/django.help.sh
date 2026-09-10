#!/usr/bin/env zsh
# 🎸 Django — a project from nothing with uv, the manage.py commands you use
# daily, and testing it with pytest-django and Playwright.
# TH_TOPIC: django
# TH_EMOJI: 🎸
# TH_DESC:  Django — startproject with uv, manage.py, migrations, pytest-django
# TH_ALSO:  get_django_testing_help | 🧪 | pytest-django, live_server and Playwright
# TH_ALSO:  get_django_deploy_help | 🚀 | production settings, static files, gunicorn
# TH_RELATED: python

_th_help_django() {
    th_head "🎸" "Django"
    th_text "The batteries-included Python web framework: ORM, migrations,"
    th_text "forms, auth, an admin site and templates, designed together."
    print -r --

    th_sub "🆕" "A project from nothing"
    th_row "Create the project:"  "uv init mysite && cd mysite"
    th_row "Add Django:"          "uv add django"
    th_row "Scaffold it here:"    "uv run django-admin startproject config ."
    th_note "the trailing dot keeps manage.py at the root"
    th_note "and settings in config/, not mysite/mysite/"
    th_row "Add an app:"          "uv run python manage.py startapp results"
    th_note "then add it to INSTALLED_APPS"
    th_note "— until then its models do not exist"
    th_row "Run it:"              "uv run python manage.py runserver"
    th_note "http://127.0.0.1:8000, reloading on every save"

    th_sub "🗃" "Models and migrations"
    th_row "Write the migration:" "uv run python manage.py makemigrations"
    th_row "Apply it:"            "uv run python manage.py migrate"
    th_row "See its SQL:"         "uv run python manage.py sqlmigrate results 0001"
    th_row "An admin login:"      "uv run python manage.py createsuperuser"
    th_row "A shell with models:" "uv run python manage.py shell"

    # Summary ends here. Everything below is the --detailed view.
    th_detail || return

    get_django_testing_help
    get_django_deploy_help
}

get_django_testing_help() {
    th_sub "🧪" "Testing with pytest-django"
    th_row "Install:"             "uv add --dev pytest pytest-django"
    th_row "Point it at settings:" "[tool.pytest.ini_options]"
    th_row ""                     "DJANGO_SETTINGS_MODULE = \"config.settings\""
    th_note "in pyproject.toml — or no test can import a model"
    th_row "Use the database:"    "@pytest.mark.django_db"
    th_note "a test gets the database only if it asks,"
    th_note "and each one is rolled back afterwards"
    th_row "The test client:"     "def test_home(client): client.get(\"/\")"
    th_row "Count the queries:"   "with django_assert_num_queries(2): …"
    th_note "the cheapest guard against an N+1 creeping back"
    th_row "Missing migrations:"  "uv run python manage.py makemigrations --check"
    th_note "run it in CI: a model changed without a migration"
    th_note "passes every test, then fails in production"
    print -r --

    th_sub "🎭" "Playwright against a real server"
    th_row "Install:"             "uv add --dev pytest-playwright"
    th_row ""                     "uv run playwright install chromium"
    th_row "A server per test:"   "def test_ui(live_server, page):"
    th_row ""                     "    page.goto(live_server.url)"
    th_note "live_server makes the test transactional, so"
    th_note "rows it creates are visible to the server"
    th_row "If the ORM refuses:"  "export DJANGO_ALLOW_ASYNC_UNSAFE=true"
    th_note "SynchronousOnlyOperation: Playwright's sync API"
    th_note "runs an event loop, and Django refuses ORM calls"
    th_note "made inside one. Tests only — never production."
}

get_django_deploy_help() {
    th_sub "🚀" "Production"
    th_row "Audit the settings:"  "uv run python manage.py check --deploy"
    th_note "catches DEBUG=True, no HSTS, open ALLOWED_HOSTS"
    th_row "Static files:"        "uv run python manage.py collectstatic --noinput"
    th_note "WhiteNoise serves them — no separate web server"
    th_row "Serve it (WSGI):"     "uv run gunicorn config.wsgi --bind 0.0.0.0:8000"
    th_row "Serve it (ASGI):"     "uv run uvicorn config.asgi:application"
    th_row "Migrate on release:"  "uv run python manage.py migrate --noinput"
    th_note "once per deploy, before new code takes traffic —"
    th_note "not per container start, where replicas race"
    th_row "The secret key:"      "SECRET_KEY = os.environ[\"SECRET_KEY\"]"
    th_note "no default on purpose: a crash on boot beats"
    th_note "a guessable key"
}
