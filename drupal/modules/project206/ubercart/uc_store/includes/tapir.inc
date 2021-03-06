<?php
// $Id: tapir.inc,v 1.1.2.8 2009/04/22 17:45:09 islandusurper Exp $

/**
 * @file
 * Contains the TAPIr code rolled into Ubercart core from Drupal contrib.
 */


/**
 * Loads a table element for use in the Forms API or simply drupal_render().
 *
 * @param $table_id
 *   The string identifying the table you want to display, like a form ID.
 * @param ...
 *   Any additional arguments will be passed on to the table builder function
 *     specified as the $table_id.
 * @return
 *   The table form element.
 */
function tapir_get_table($table_id) {
  // Get any additional arguments.
  $args = func_get_args();

  array_shift($args);

  // Retrieve the table data and allow modules to alter it.
  $table = call_user_func_array($table_id, $args);

  array_unshift($args, $table_id);

  $data = &$table;
  // Pass the arguments in the table so that alter functions can use them.
  $data['#parameters'] = $args;

  drupal_alter('tapir_table', $data, $table_id);

  return $table;
}

/**
 * Pre-render callback for tapir_table elements.
 *
 * Gathers children of the tapir_table element into the #rows array. This
 * allows the element to render the children within the table as rows. Non-row
 * children are rendered after the table.
 */
function tapir_gather_rows($element) {
  foreach (element_children($element) as $row) {
    foreach (array_keys($element['#columns']) as $col_id) {
      $element['#rows'][$row][$col_id] = $element[$row][$col_id];
      unset($element[$row][$col_id]);
    }
    $element['#rows'][$row]['#attributes'] = isset($element[$row]['#attributes']) ? $element[$row]['#attributes'] : array();
  }

  return $element;
}

/**
 * Themes form data into a table for display.
 *
 * @param $form
 *   The array of form information needing to be rendered into the table.
 * @return
 *   The table output rendered in HTML.
 * @ingroup themeable
 */
function theme_tapir_table($element) {
  $header = array();
  $rows = array();

  // First sort the columns by weight.
  uasort($element['#columns'], 'uc_weight_sort');

  // Loop through the columns and create the header array.
  foreach ($element['#columns'] as $col_id => $col_data) {
    // Add the cell if available.
    if (!isset($col_data['access']) || $col_data['access'] !== FALSE) {
      $header[] = $col_data['cell'];
    }
  }

  // Loop through the row data and create rows with the data in the right order.
  foreach ($element['#rows'] as $data) {
    $attributes = array();
    $row = array();

    /* // If the row combines cell data with attributes...
    if (isset($data['data'])) {
      // Set the attributes array to be everything in the row array except the
      // data array.
      $attributes = $data;
      unset($attributes['data']);

      // Filter the data array down to just the cell data.
      $data = $data['data'];
    } */

    // Loop through each column in the header.
    foreach ($element['#columns'] as $col_id => $col_data) {
      // If this row defines cell data for the current column...
      if ((!isset($col_data['access']) || $col_data['access'] !== FALSE) && isset($data[$col_id])) {
        $cell = array();
        if (isset($data[$col_id]['#cell_attributes']) && is_array($data[$col_id]['#cell_attributes'])) {
          foreach ($data[$col_id]['#cell_attributes'] as $property => $value) {
            if ($property == 'colspan' && $value == 'full') {
              // Extend full-width cells to the number of columns actually
              // displayed.
              $value = count($header);
            }
            $cell[$property] = $value;
          }
          $cell['data'] = drupal_render($data[$col_id]);
        }
        else {
          $cell = drupal_render($data[$col_id]);
        }
        // Add it to the row array.
        $row[] = $cell;
      }
    }

    // Merge the row data into a single row array along with the attributes.
    $row = array_merge(array('data' => $row), (array)$data['#attributes']);

    // Add the current row to the table rows array.
    $rows[] = $row;
  }

  // Return the rendered table.
  return theme('table', $header, $rows, (array)$element['#attributes'], $element['#title']) . (isset($element['#children']) ? $element['#children'] : '');
}

/**
 * Builds an ORDER BY clause for a table's SELECT query based on the table's
 *   columns.
 *
 * @param $columns
 *   The column array from a TAPIr table array.
 * @return
 *   The result of a tablesort_sql() call on the header info for this table.
 */
function tapirsort_sql($columns) {
  $header = array();

  // Loop through the columns array...
  foreach ($columns as $column) {
    // And build a header array based on column information.
    $header[] = $column['cell'];
  }

  // Return the result of a tablesort on our header.
  return tablesort_sql($header);
}

function uc_store_form_alter(&$form, &$form_state, $form_id) {
  if ($form_id == 'uc_product_table') {
    unset($form['table']['#value']['columns']['list_price']);
  }
}

