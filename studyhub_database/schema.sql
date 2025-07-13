-- StudyHub Database Schema (PostgreSQL)
-- Users, Study Notes, Decks, Sharing/Permissions, Interactions

-- DROP TABLE IF EXISTS statements for development resets
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS likes;
DROP TABLE IF EXISTS sharing_permissions;
DROP TABLE IF EXISTS notes;
DROP TABLE IF EXISTS decks;
DROP TABLE IF EXISTS users;

-- USERS TABLE
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(32) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    display_name VARCHAR(64),
    bio TEXT,
    avatar_url VARCHAR(512),
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);

-- DECKS TABLE
CREATE TABLE decks (
    deck_id SERIAL PRIMARY KEY,
    owner_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(128) NOT NULL,
    description TEXT,
    is_public BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_decks_owner_id ON decks(owner_id);
CREATE INDEX idx_decks_is_public ON decks(is_public);

-- NOTES TABLE
CREATE TABLE notes (
    note_id SERIAL PRIMARY KEY,
    deck_id INTEGER NOT NULL REFERENCES decks(deck_id) ON DELETE CASCADE,
    author_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE SET NULL,
    title VARCHAR(128),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notes_deck_id ON notes(deck_id);
CREATE INDEX idx_notes_author_id ON notes(author_id);

-- SHARING PERMISSIONS TABLE
-- Allows sharing decks with specific users (private shares)
CREATE TABLE sharing_permissions (
    permission_id SERIAL PRIMARY KEY,
    deck_id INTEGER NOT NULL REFERENCES decks(deck_id) ON DELETE CASCADE,
    shared_with_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    can_edit BOOLEAN NOT NULL DEFAULT FALSE,
    granted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(deck_id, shared_with_id)
);

CREATE INDEX idx_sharing_permissions_deck_id ON sharing_permissions(deck_id);
CREATE INDEX idx_sharing_permissions_shared_with_id ON sharing_permissions(shared_with_id);

-- LIKES TABLE (for both notes and decks, polymorphic by type)
CREATE TABLE likes (
    like_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    target_type VARCHAR(16) NOT NULL CHECK (target_type IN ('note', 'deck')),
    target_id INTEGER NOT NULL,
    liked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, target_type, target_id)
);

CREATE INDEX idx_likes_user_id ON likes(user_id);
CREATE INDEX idx_likes_target ON likes(target_type, target_id);

-- COMMENTS TABLE (for both notes and decks, polymorphic by type)
CREATE TABLE comments (
    comment_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    target_type VARCHAR(16) NOT NULL CHECK (target_type IN ('note', 'deck')),
    target_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_comments_target ON comments(target_type, target_id);

-- Future extensions: tags, attachments, versioning, notifications, etc.

-- Foreign key constraints for polymorphic targets (handled at application layer)
-- Optionally, you can add triggers to enforce integrity (not included here for brevity).

-- End of StudyHub schema.sql
