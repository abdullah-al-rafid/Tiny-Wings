const { test, expect } = require('@playwright/test');

const accounts = {
  admin: { email: 'admin@gmail.com', password: 'TinyWings2024!' },
  manager: { email: 'shelter@helper.org', password: 'TinyWings2024!' },
  donor: { email: 'saymum.rahman@tinywings.bd', password: 'TinyWings2024!' },
  volunteer: { email: 'rahim@volunteer.bd', password: 'TinyWings2024!' },
};

async function openLogin(page) {
  await page.goto('/', { waitUntil: 'domcontentloaded' });
  await enableAccessibility(page);
  await expect(page.getByText('TinyWings')).toBeVisible();
  await page.getByText('Login', { exact: true }).click();
  await expect(page.getByText('Welcome Back')).toBeVisible();
}

async function enableAccessibility(page) {
  const enableButton = page.getByRole('button', {
    name: 'Enable accessibility',
  });
  if (await enableButton.isVisible().catch(() => false)) {
    await enableButton.click();
  }
}

async function login(page, account) {
  await openLogin(page);
  await page.getByRole('textbox').first().fill(account.email);
  await page.locator('input[type="password"]').fill(account.password);
  await page.getByRole('button', { name: 'Login' }).click();
  await expect(page.getByText(/Welcome Back,/)).toBeVisible();
}

test.describe.serial('TinyWings release verification', () => {
  test('release build loads in Edge', async ({ page }) => {
    await page.goto('/', { waitUntil: 'domcontentloaded' });
    await enableAccessibility(page);
    await expect(page.getByText('TinyWings')).toBeVisible();
    await expect(page.getByText('Login', { exact: true })).toBeVisible();
  });

  test('admin can seed realistic production data', async ({ page }) => {
    await login(page, accounts.admin);
    await page.getByText('Admin Dashboard').click();
    await expect(page.getByText('Initialize Production Data')).toBeVisible();
    await page.getByText('Initialize Production Data').click();
    await expect(page.getByText('Production Database Initialized!')).toBeVisible({
      timeout: 120_000,
    });

    await page.goto('/organizations', { waitUntil: 'domcontentloaded' });
    await expect(
      page.getByText('Shapla Child Development Home'),
    ).toBeVisible();

    await page.reload({ waitUntil: 'domcontentloaded' });
    await expect(
      page.getByText('Shapla Child Development Home'),
    ).toBeVisible();
  });

  test('donor can sign in and see seeded platform activity', async ({ page }) => {
    await login(page, accounts.donor);
    await page.goto('/home', { waitUntil: 'domcontentloaded' });
    await expect(page.getByText('Featured Organizations')).toBeVisible();
    await expect(page.getByText('Shapla Child Development Home')).toBeVisible();

    await page.goto('/notifications', { waitUntil: 'domcontentloaded' });
    await expect(page.getByText('Sponsorship update from Shapla Home')).toBeVisible();
  });
});
