import os
import uuid
from playwright.sync_api import Page

STAGING_URL = os.environ.get(
    "STAGING_URL", "http://localhost:5000")

STUDENT_NAME = "E2E-%s" % uuid.uuid4().hex[:8]

def test_homepage_loads(page: Page):
    """Home page returns content."""
    page.goto(STAGING_URL)
    assert page.title() != ""

def test_add_student_workflow(page: Page):
    """Fill form, submit, confirm redirect."""
    page.goto(f"{STAGING_URL}/new")
    page.fill("input[name='name']", STUDENT_NAME)
    page.fill("input[name='city']", "Miami")
    page.fill("input[name='addr']", "123 Main St")
    page.fill("input[name='pin']", "33101")
    page.fill("input[name='phone_number']", "305-555-9999")
    page.click("button[type='submit']")
    page.wait_for_url(STAGING_URL + "/")

def test_student_appears_on_list(page: Page):
    """Created above; runs after it in file order."""
    page.goto(STAGING_URL)
    assert STUDENT_NAME in page.content()

def test_missing_name_stays_on_form(page: Page):
    """Browser blocks submit with blank name in form, no redirect."""
    page.goto(f"{STAGING_URL}/new")
    page.fill("input[name='city']", "Miami")
    page.fill("input[name='addr']", "1 Main St")
    page.fill("input[name='phone_number']", "305-555-0000")
    page.click("button[type='submit']")
    assert "/new" in page.url
