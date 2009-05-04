<?php
// $Id: default.profile,v 1.22 2007/12/17 12:43:34 goba Exp $
 
/**
 * Return an array of the modules to be enabled when this profile is installed.
 *
 * @return
 * An array of modules to enable.
 */
function project206_profile_modules() {
  $core_modules = array(
    // Required core modules.
    'block', 'filter', 'node', 'system', 'user',

    // Optional core modules.
    'dblog', 'menu', 'search', 'taxonomy', 'trigger', 'update', 'path', 'color',
    'php',
  );

  $contributed_modules = array(
    // Contributed modules.
    'imageapi', 'imagecache', 'token', 'pathauto', 'captcha', 'bueditor', 'themesettingsapi','admin_menu', 'content', 'views', 'views_ui', 'devel', 'content_permissions', 'number', 'text', 'optionwidgets', 'filefield', 'imagefield', 'imageapi_gd',
  );

  return array_merge($core_modules, $contributed_modules);
} 
/**
 * Return a description of the profile for the initial installation screen.
 *
 * @return
 * An array with keys 'name' and 'description' describing this profile,
 * and optional 'language' to override the language selection for
 * language-specific profiles.
 */
function project206_profile_details() {
  return array(
    'name' => 'Project206',
    'description' => 'A flavor of Drupal that only someone in the 206 could appreciate.'
  );
}
 
/**
 * Return a list of tasks that this profile supports.
 *
 * @return
 * A keyed array of tasks the profile will perform during
 * the final stage. The keys of the array will be used internally,
 * while the values will be displayed to the user in the installer
 * task list.
 */
function project206_profile_task_list() {
  // This is the only profile method that is invoked before the first page is
  // displayed during the install sequence. Use this opportunity to theme the
  // install experience.
  global $conf;
  $conf['theme_settings'] = array(
    'default_logo' => 0,
    'logo_path' => 'profiles/project206/Project206DrupalLogo.png');
  $conf['site_name'] = 'Setup Wizard';
}

/**
 * Perform any final installation tasks for this profile.
 *
 * The installer goes through the profile-select -> locale-select
 * -> requirements -> database -> profile-install-batch
 * -> locale-initial-batch -> configure -> locale-remaining-batch
 * -> finished -> done tasks, in this order, if you don't implement
 * this function in your profile.
 *
 * If this function is implemented, you can have any number of
 * custom tasks to perform after 'configure', implementing a state
 * machine here to walk the user through those tasks. First time,
 * this function gets called with $task set to 'profile', and you
 * can advance to further tasks by setting $task to your tasks'
 * identifiers, used as array keys in the hook_profile_task_list()
 * above. You must avoid the reserved tasks listed in
 * install_reserved_tasks(). If you implement your custom tasks,
 * this function will get called in every HTTP request (for form
 * processing, printing your information screens and so on) until
 * you advance to the 'profile-finished' task, with which you
 * hand control back to the installer. Each custom page you
 * return needs to provide a way to continue, such as a form
 * submission or a link. You should also set custom page titles.
 *
 * You should define the list of custom tasks you implement by
 * returning an array of them in hook_profile_task_list(), as these
 * show up in the list of tasks on the installer user interface.
 *
 * Remember that the user will be able to reload the pages multiple
 * times, so you might want to use variable_set() and variable_get()
 * to remember your data and control further processing, if $task
 * is insufficient. Should a profile want to display a form here,
 * it can; the form should set '#redirect' to FALSE, and rely on
 * an action in the submit handler, such as variable_set(), to
 * detect submission and proceed to further tasks. See the configuration
 * form handling code in install_tasks() for an example.
 *
 * Important: Any temporary variables should be removed using
 * variable_del() before advancing to the 'profile-finished' phase.
 *
 * @param $task
 * The current $task of the install system. When hook_profile_tasks()
 * is first called, this is 'profile'.
 * @param $url
 * Complete URL to be used for a link or form action on a custom page,
 * if providing any, to allow the user to proceed with the installation.
 *
 * @return
 * An optional HTML string to display to the user. Only used if you
 * modify the $task, otherwise discarded.
 */
 
function project206_profile_tasks(&$task, $url) {
  global $language;
  
	// Change to Simply Modern theme.
	$themes = system_theme_data();
	$theme = 'simply_modern';
	if (isset($themes[$theme])) {
		system_initialize_theme_blocks($theme);
		db_query("Update {system} SET status = 1 WHERE type = 'theme' AND name = '%s'", $theme);
		variable_set('theme_default', $theme);		
		menu_rebuild();
		drupal_rebuild_theme_registry();
	}  
  
  // Insert default user-defined node types into the database. For a complete
  // list of available node type attributes, refer to the node type API
  // documentation at: http://api.drupal.org/api/HEAD/function/hook_node_info.
  $types = array(
    array(
      'type' => 'page',
      'name' => st('Page'),
      'module' => 'node',
      'description' => st("A static page, does not allow comments and is meant for items like the About Us page."),
      'custom' => TRUE,
      'modified' => TRUE,
      'locked' => FALSE,
      'help' => '',
      'min_word_count' => '',
    ),
    array(
      'type' => 'page4comment',
      'name' => st('Page with Comments'),
      'module' => 'node',
      'description' => st("A page that has comments enabled."),
      'custom' => TRUE,
      'modified' => TRUE,
      'locked' => FALSE,
      'help' => '',
      'min_word_count' => '',
    ),
  );
 
  foreach ($types as $type) {
    $type = (object) _node_type_set_defaults($type);
    node_type_save($type);
  }
 
  // Default page to not be promoted and have comments disabled.
  variable_set('node_options_page', array('status'));
  variable_set('comment_page', COMMENT_NODE_DISABLED);
}