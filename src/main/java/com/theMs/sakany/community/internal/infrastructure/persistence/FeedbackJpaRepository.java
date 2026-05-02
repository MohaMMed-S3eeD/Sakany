package com.theMs.sakany.community.internal.infrastructure.persistence;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface FeedbackJpaRepository extends JpaRepository<FeedbackEntity, UUID> {
    List<FeedbackEntity> findAllByOrderByCreatedAtDesc();
    List<FeedbackEntity> findByIsPublicTrueAndStatusInOrderByCreatedAtDesc(List<String> statuses);
    List<FeedbackEntity> findByAuthorIdOrderByCreatedAtDesc(UUID authorId);

    @Query(value = """
            SELECT
                f.id AS feedbackId,
                f.author_id AS authorId,
                u.first_name AS authorFirstName,
                u.last_name AS authorLastName,
                un.unit_number AS unitNumber,
                f.title AS title,
                f.content AS content,
                f.type AS type,
                f.is_public AS isPublic,
                f.status AS workflowStatus,
                f.upvotes AS upvotes,
                f.downvotes AS downvotes,
                f.category AS category,
                f.location AS location,
                f.is_anonymous AS isAnonymous,
                f.admin_response AS adminResponse,
                f.image_url AS imageUrl,
                f.view_count AS viewCount,
                f.created_at AS createdAt
            FROM feedback f
            LEFT JOIN users u ON u.id = f.author_id
            LEFT JOIN resident_profiles rp ON rp.user_id = u.id
            LEFT JOIN units un ON un.id = rp.unit_id
            WHERE (:isPublic IS NULL OR f.is_public = :isPublic)
              AND (:type IS NULL OR f.type = :type)
            ORDER BY f.created_at DESC
            """, nativeQuery = true)
    List<AdminFeedbackDashboardRow> findAdminFeedbackRows(
            @Param("isPublic") Boolean isPublic,
            @Param("type") String type
    );

    @Query(value = """
            SELECT
                f.id AS feedbackId,
                f.author_id AS authorId,
                u.first_name AS authorFirstName,
                u.last_name AS authorLastName,
                un.unit_number AS unitNumber,
                f.title AS title,
                f.content AS content,
                f.type AS type,
                f.is_public AS isPublic,
                f.status AS workflowStatus,
                f.upvotes AS upvotes,
                f.downvotes AS downvotes,
                f.category AS category,
                f.location AS location,
                f.is_anonymous AS isAnonymous,
                f.admin_response AS adminResponse,
                f.image_url AS imageUrl,
                f.view_count AS viewCount,
                f.created_at AS createdAt
            FROM feedback f
            LEFT JOIN users u ON u.id = f.author_id
            LEFT JOIN resident_profiles rp ON rp.user_id = u.id
            LEFT JOIN units un ON un.id = rp.unit_id
            WHERE f.id = :feedbackId
            """, nativeQuery = true)
    Optional<AdminFeedbackDashboardRow> findAdminFeedbackRowById(@Param("feedbackId") UUID feedbackId);

    @Query(value = """
            SELECT
                COALESCE(SUM(CASE WHEN f.is_public = TRUE AND f.type = 'SUGGESTION' THEN 1 ELSE 0 END), 0) AS publicSuggestionsCount,
                COALESCE(SUM(CASE WHEN f.is_public = FALSE THEN 1 ELSE 0 END), 0) AS privateFeedbackCount,
                COALESCE(SUM(CASE WHEN f.is_public = TRUE AND f.type = 'SUGGESTION' THEN 1 ELSE 0 END), 0) AS totalSuggestions,
                COALESCE(SUM(CASE WHEN f.is_public = TRUE AND f.type = 'SUGGESTION' AND f.status IN ('OPEN', 'UNDER_REVIEW') THEN 1 ELSE 0 END), 0) AS pendingReviewCount,
                COALESCE(SUM(CASE WHEN f.is_public = TRUE AND f.type = 'SUGGESTION' THEN COALESCE(f.upvotes, 0) + COALESCE(f.downvotes, 0) ELSE 0 END), 0) AS totalVotes,
                COALESCE(SUM(CASE WHEN f.is_public = TRUE AND f.type = 'SUGGESTION' AND (COALESCE(f.upvotes, 0) + COALESCE(f.downvotes, 0)) >= 20 THEN 1 ELSE 0 END), 0) AS popularCount
            FROM feedback f
            """, nativeQuery = true)
    AdminFeedbackSummaryRow getAdminFeedbackSummary();

    @Query(value = """
            SELECT DISTINCT f.category
            FROM feedback f
            WHERE f.category IS NOT NULL
              AND TRIM(f.category) <> ''
            ORDER BY f.category
            """, nativeQuery = true)
    List<String> findDistinctFeedbackCategories();

    @Modifying
    @Query(value = """
            UPDATE feedback
            SET admin_response = :adminResponse,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = :feedbackId
            """, nativeQuery = true)
    int updateAdminResponse(@Param("feedbackId") UUID feedbackId, @Param("adminResponse") String adminResponse);

    @Modifying
    @Query(value = """
            UPDATE feedback
            SET view_count = COALESCE(view_count, 0) + 1,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = :feedbackId
            """, nativeQuery = true)
    int incrementViewCount(@Param("feedbackId") UUID feedbackId);
}
