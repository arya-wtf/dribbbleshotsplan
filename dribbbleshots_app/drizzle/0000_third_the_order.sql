CREATE TABLE `admin_reviews` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`plan_id` integer NOT NULL,
	`reviewer_id` integer NOT NULL,
	`decision` text NOT NULL,
	`field_notes_json` text NOT NULL,
	`created_at` integer NOT NULL,
	FOREIGN KEY (`plan_id`) REFERENCES `shot_plans`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`reviewer_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE TABLE `ai_evaluations` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`plan_id` integer NOT NULL,
	`score` real NOT NULL,
	`label` text NOT NULL,
	`score_breakdown_json` text NOT NULL,
	`field_feedback_json` text NOT NULL,
	`overall_verdict` text NOT NULL,
	`created_at` integer NOT NULL,
	FOREIGN KEY (`plan_id`) REFERENCES `shot_plans`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE TABLE `notifications` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`user_id` integer NOT NULL,
	`plan_id` integer,
	`message` text NOT NULL,
	`type` text NOT NULL,
	`is_read` integer DEFAULT false NOT NULL,
	`created_at` integer NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`plan_id`) REFERENCES `shot_plans`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE TABLE `shot_plans` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`designer_id` integer NOT NULL,
	`parent_plan_id` integer,
	`revision_number` integer DEFAULT 1 NOT NULL,
	`general_theme_id` integer NOT NULL,
	`specific_theme` text NOT NULL,
	`title` text NOT NULL,
	`product_type` text NOT NULL,
	`target_market` text NOT NULL,
	`app_explanation` text NOT NULL,
	`sections_json` text,
	`screens_json` text,
	`pages_json` text,
	`ref_links_json` text,
	`status` text DEFAULT 'draft' NOT NULL,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	FOREIGN KEY (`designer_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`general_theme_id`) REFERENCES `theme_library`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE TABLE `theme_library` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`macro_theme` text NOT NULL,
	`niche_name` text NOT NULL,
	`country_fit` text NOT NULL,
	`buyer_fit` text NOT NULL,
	`visual_potential` integer DEFAULT 70 NOT NULL,
	`authority_score` integer DEFAULT 70 NOT NULL,
	`business_relevance` integer DEFAULT 70 NOT NULL,
	`discovery_score` integer DEFAULT 70 NOT NULL,
	`generic_penalty` integer DEFAULT 0 NOT NULL,
	`notes` text
);
--> statement-breakpoint
CREATE TABLE `users` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`username` text NOT NULL,
	`password_hash` text NOT NULL,
	`role` text DEFAULT 'designer' NOT NULL,
	`created_at` integer NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX `users_username_unique` ON `users` (`username`);