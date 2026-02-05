// lib/services/sync/descriptors/recipe_ingredients_descriptor.dart

import '../table_sync_descriptor.dart';
import '../sync_conflict.dart';

/// Descriptor for RecipeIngredients table sync
/// 
/// Tier 3: Depends on Items, Ingredients
/// Push: Only commissary can push recipe ingredients
/// Note: item_id and ingredient_id are INTEGER in Supabase (not UUID)
final recipeIngredientsDescriptor = TableSyncDescriptor(
  tableName: 'recipe_ingredients',
  cloudTableName: 'recipe_ingredients',
  conflictResolution: ConflictResolution.lastWriteWins,
  dependencyTier: 3,
  softDeleteField: 'is_deleted',
  
  // Only commissary creates recipes
  canPush: (orgType) => orgType == 'commissary',
  
  foreignKeys: [
    // NOTE: item_id and ingredient_id are INTEGER in Supabase, not UUID
    ForeignKeyMapping(
      localField: 'itemId',
      cloudField: 'item_id',
      referenceTable: 'items',
      required: true,
      cloudUsesUuid: false, // Integer, not UUID
    ),
    ForeignKeyMapping(
      localField: 'ingredientId',
      cloudField: 'ingredient_id',
      referenceTable: 'ingredients',
      required: true,
      cloudUsesUuid: false, // Integer, not UUID
    ),
  ],
  
  fieldMappings: [
    FieldMapping.simple('quantityNeeded', 'quantity_needed'),
    FieldMapping.simple('unit', 'unit'),
    FieldMapping.simple('notes', 'notes'),
    FieldMapping.boolean('isDeleted', 'is_deleted'),
    FieldMapping.dateTime('createdAt', 'created_at'),
    FieldMapping.dateTime('lastUpdated', 'last_updated'),
  ],
);
