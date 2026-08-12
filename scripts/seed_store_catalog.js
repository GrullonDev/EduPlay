/**
 * One-off admin migration for the Tienda catalog (Firestore `storeCatalog`
 * collection). Run this by hand from a trusted machine — it authenticates
 * with the Firebase Admin SDK, which bypasses firestore.rules entirely, so
 * it is NOT something the app itself (or any signed-in user, including an
 * admin in the in-app catalog editor) can trigger. That's the point: the
 * app's `AdminStoreCatalogPage` "Restaurar valores por defecto" button is
 * the day-to-day admin tool (gated by `parents/{uid}.role == 'admin'`);
 * this script is for the *initial* seed of a fresh project/environment, or
 * a bulk migration, before any admin account necessarily exists yet.
 *
 * The item list below is a hand-kept mirror of the Dart seed data in
 * lib/features/store/models/store_item.dart (`allStoreItems`). There is no
 * automated sync between the two — if you add/edit an item in one place,
 * update the other, or just use this script once for the initial seed and
 * do all further edits through AdminStoreCatalogPage instead.
 *
 * Usage:
 *   cd scripts
 *   npm install
 *   node seed_store_catalog.js                  # uses Application Default
 *                                                # Credentials (gcloud auth
 *                                                # application-default login)
 *   GOOGLE_APPLICATION_CREDENTIALS=./sa.json node seed_store_catalog.js
 *                                                # or a downloaded service
 *                                                # account key instead
 *
 * By default this only creates documents that don't exist yet (safe to
 * re-run). Pass --force to overwrite existing documents too, e.g. after
 * intentionally editing the list below.
 */

const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

const db = admin.firestore();

/** Mirrors StoreCategory in store_item.dart. */
const CATEGORY = {
  avatarColor: 'avatarColor',
  avatarIcon: 'avatarIcon',
  sticker: 'sticker',
};

// Mirrors allStoreItems in lib/features/store/models/store_item.dart.
// colorValue is the ARGB32 int Flutter's Color.toARGB32() would produce.
const CATALOG = [
  { id: 'avatar_color_ruby', name: 'Rubí', category: CATEGORY.avatarColor, cost: 40, colorValue: 0xFFE53935 },
  { id: 'avatar_color_emerald', name: 'Esmeralda', category: CATEGORY.avatarColor, cost: 40, colorValue: 0xFF00C853 },
  { id: 'avatar_color_sapphire', name: 'Zafiro', category: CATEGORY.avatarColor, cost: 40, colorValue: 0xFF2962FF },
  { id: 'avatar_color_amber', name: 'Ámbar', category: CATEGORY.avatarColor, cost: 40, colorValue: 0xFFFFAB00 },
  { id: 'avatar_color_gold', name: 'Oro Real', category: CATEGORY.avatarColor, cost: 90, colorValue: 0xFFFFC107, minLevel: 3, isFeatured: true },

  { id: 'avatar_icon_star', name: 'Estrella', category: CATEGORY.avatarIcon, cost: 60, iconKey: 'star' },
  { id: 'avatar_icon_rocket', name: 'Cohete', category: CATEGORY.avatarIcon, cost: 80, iconKey: 'rocket', isFeatured: true },
  { id: 'avatar_icon_bolt', name: 'Rayo', category: CATEGORY.avatarIcon, cost: 100, iconKey: 'bolt' },
  { id: 'avatar_icon_sparkle', name: 'Destello', category: CATEGORY.avatarIcon, cost: 120, iconKey: 'sparkle', minLevel: 2 },

  { id: 'unicorn', name: 'Unicornio Mágico', category: CATEGORY.sticker, cost: 150, iconKey: 'sparkle', isProOnly: true },
  { id: 'diamond', name: 'Diamante Brillante', category: CATEGORY.sticker, cost: 200, iconKey: 'diamond', isProOnly: true, isFeatured: true },
  { id: 'crown', name: 'Corona Real', category: CATEGORY.sticker, cost: 250, iconKey: 'crown', isProOnly: true, minLevel: 4 },
  { id: 'dragon', name: 'Dragón de Fuego', category: CATEGORY.sticker, cost: 300, iconKey: 'dragon_fire', isProOnly: true, minLevel: 5 },
];

function toDoc(item) {
  return {
    id: item.id,
    name: item.name,
    category: item.category,
    cost: item.cost,
    isProOnly: item.isProOnly ?? false,
    minLevel: item.minLevel ?? 1,
    isFeatured: item.isFeatured ?? false,
    ...(item.colorValue !== undefined ? { colorValue: item.colorValue } : {}),
    ...(item.iconKey !== undefined ? { iconKey: item.iconKey } : {}),
    ...(item.availableFrom ? { availableFrom: item.availableFrom } : {}),
    ...(item.availableUntil ? { availableUntil: item.availableUntil } : {}),
  };
}

async function main() {
  const force = process.argv.includes('--force');
  const collection = db.collection('storeCatalog');

  let created = 0;
  let skipped = 0;
  let overwritten = 0;

  for (const item of CATALOG) {
    const ref = collection.doc(item.id);
    const existing = await ref.get();

    if (existing.exists && !force) {
      skipped++;
      continue;
    }

    await ref.set(toDoc(item));
    if (existing.exists) {
      overwritten++;
    } else {
      created++;
    }
  }

  console.log(
    `Done. Created ${created}, overwritten ${overwritten}, skipped ${skipped} (already existed, use --force to overwrite).`,
  );
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('seed_store_catalog failed:', err);
    process.exit(1);
  });
