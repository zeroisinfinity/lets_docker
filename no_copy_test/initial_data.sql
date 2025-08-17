CREATE TABLE IF NOT EXISTS `domain_image` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `image_url` varchar(200) NOT NULL,
  `idd` int NOT NULL,
  PRIMARY KEY (`id`)
);

INSERT IGNORE INTO `domain_image` (`id`, `title`, `image_url`, `idd`) VALUES
(1, 'Frontend', 'https://images.shiksha.com/mediadata/ugcDocuments/images/wordpressImages/2021_12_learn-front-end-development-1.jpg', 1),
(2, 'AI/ML', 'https://www.asterhospitals.in/sites/default/files/styles/webp/public/2023-09/The%20Intersection%20of%20Neuroscience%20and%20AI%20Understanding%20the%20Human%20Brain_Blog%20Image.png.webp?itok=U2LurI98', 2),
(3, 'Backend', 'https://images.ctfassets.net/xri6xnn81z4a/EoOvRyIMaGbMjPcrqIgwb/70524abc0a6a50732e8a28a57864efb0/Backend-Development.jpg', 3),
(4, 'Data science', 'https://cdn.prod.website-files.com/63ccf2f0ea97be12ead278ed/644a18b637053fa3709c5ba2_what-is-data-science-p-800.jpg', 4),
(5, 'Web Development', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShhg-3ZBqyo9vi6xjDksNfCI_ayNSXWgkY3g&s', 5),
(6, 'Mobile App Development', 'https://www.addevice.io/storage/ckeditor/uploads/images/65f840d316353_mobile.app.development.1920.1080.png', 6),
(7, 'Cybersecurity', 'https://business.defense.gov/portals/57/Images/cyber-carousel/cyber-slide1.jpg?ver=_ACNVKwiING6pUukzdhhWw%3d%3d', 7),
(8, 'Cloud Computing', 'https://plus.unsplash.com/premium_photo-1683141114059-aaeaf635dc05?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Y2xvdWQlMjBjb21wdXRpbmd8ZW58MHx8MHx8fDA%3D', 8),
(9, 'DevOps', 'https://devopedia.org/images/article/54/7602.1513404277.png', 9),
(10, 'Blockchain', 'https://online.stanford.edu/sites/default/files/inline-images/1600X900-How-does-blockchain-work.jpg', 10);

CREATE TABLE IF NOT EXISTS `prob_statements_frontend` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `question` varchar(255) NOT NULL,
  `description` longtext,
  `difficulty` varchar(50) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
);

INSERT IGNORE INTO `prob_statements_frontend` (`id`, `question`, `description`, `difficulty`, `created_at`) VALUES
(1, 'How can you create a responsive navbar that collapses into a hamburger menu on smaller screens?', 'Build a responsive navigation bar that adjusts to different screen sizes. Use CSS Flexbox or Grid for layout and media queries to handle responsiveness. Ensure the navbar includes a dropdown menu and a toggleable hamburger menu for mobile devices.', 'Medium', '2025-03-20 04:42:02.421737'),
(2, 'How can you implement real-time form validation using JavaScript?', 'Create a user registration form with fields for name, email, password, and confirm password. Use JavaScript to validate the form in real-time, displaying error messages for invalid inputs (e.g., invalid email format, password mismatch).', 'Medium', '2025-03-20 04:42:34.330513'),
(3, 'How would you create a modal popup that can be opened and closed using JavaScript or a frontend framework?', 'This question tests your skills in building interactive UI components. A modal is a common UI pattern, and candidates should be able to demonstrate the use of CSS for styling and JavaScript (or React/Vue if applicable) to handle show/hide functionality. The modal should also include features like closing on clicking outside the modal or pressing the escape key.', 'Hard', '2025-03-28 04:20:54.472334'),
(4, 'How would you build a pagination component to navigate through a list of items, showing a fixed number of items per page?', 'This question tests your ability to create components that manage state and handle user interaction. You should mention using JavaScript or a frontend framework to handle page navigation and display the correct data for each page. Key topics include state management, conditionally rendering pages, and making sure the UI is accessible.', 'Hard', '2025-03-28 04:21:26.144022'),
(5, 'How would you create a customizable dashboard where users can add, remove, or rearrange widgets dynamically?', 'This question evaluates your ability to build a highly interactive and stateful frontend application. Candidates should explain how to manage the layout dynamically (using Drag-and-Drop or React Grid Layout), store widget data, and provide a user-friendly UI.', 'Hard', '2025-03-28 04:23:06.819368');

CREATE TABLE IF NOT EXISTS `prob_statements_ai_ml` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `question` varchar(255) NOT NULL,
  `description` longtext,
  `difficulty` varchar(50) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `prob_statements_backend` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `question` varchar(255) NOT NULL,
  `description` longtext,
  `difficulty` varchar(50) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `prob_statements_blockchain` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `question` varchar(255) NOT NULL,
  `description` longtext,
  `difficulty` varchar(50) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `prob_statements_cloud_computing` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `question` varchar(255) NOT NULL,
  `description` longtext,
  `difficulty` varchar(50) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `prob_statements_cybersecurity` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `question` varchar(255) NOT NULL,
  `description` longtext,
  `difficulty` varchar(50) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `prob_statements_data_science` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `question` varchar(255) NOT NULL,
  `description` longtext,
  `difficulty` varchar(50) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `prob_statements_dev_ops` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `question` varchar(255) NOT NULL,
  `description` longtext,
  `difficulty` varchar(50) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `prob_statements_mobile_app_dev` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `question` varchar(255) NOT NULL,
  `description` longtext,
  `difficulty` varchar(50) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `prob_statements_web_development` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `question` varchar(255) NOT NULL,
  `description` longtext,
  `difficulty` varchar(50) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
);
