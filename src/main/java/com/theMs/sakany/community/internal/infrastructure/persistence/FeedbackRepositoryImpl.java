package com.theMs.sakany.community.internal.infrastructure.persistence;

import com.theMs.sakany.community.internal.domain.Feedback;
import com.theMs.sakany.community.internal.domain.FeedbackRepository;
import com.theMs.sakany.community.internal.domain.VoteType;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Repository
public class FeedbackRepositoryImpl implements FeedbackRepository {

    private final FeedbackJpaRepository jpaRepository;
    private final FeedbackVoteJpaRepository voteJpaRepository;
    private final FeedbackMapper mapper;
    private final ApplicationEventPublisher eventPublisher;

    public FeedbackRepositoryImpl(FeedbackJpaRepository jpaRepository, FeedbackVoteJpaRepository voteJpaRepository, FeedbackMapper mapper, ApplicationEventPublisher eventPublisher) {
        this.jpaRepository = jpaRepository;
        this.voteJpaRepository = voteJpaRepository;
        this.mapper = mapper;
        this.eventPublisher = eventPublisher;
    }

    @Override
    public Feedback save(Feedback feedback) {
        FeedbackEntity entity = mapper.toEntity(feedback);
        FeedbackEntity savedEntity = jpaRepository.save(entity);

        // Publish events
        feedback.getDomainEvents().forEach(eventPublisher::publishEvent);
        feedback.clearDomainEvents();

        return mapper.toDomain(savedEntity);
    }

    @Override
    public Optional<Feedback> findById(UUID id) {
        return jpaRepository.findById(id).map(mapper::toDomain);
    }

    @Override
    public List<Feedback> findAllOrderByCreatedAtDesc() {
        return jpaRepository.findAllByOrderByCreatedAtDesc().stream()
                .map(mapper::toDomain)
                .collect(Collectors.toList());
    }

    @Override
    public List<Feedback> findPublicFeedback() {
        return jpaRepository.findByIsPublicTrueAndStatusInOrderByCreatedAtDesc(
                List.of("APPROVED", "ADDRESSED")
        ).stream()
                .map(mapper::toDomain)
                .collect(Collectors.toList());
    }

    @Override
    public List<Feedback> findByAuthorId(UUID authorId) {
        return jpaRepository.findByAuthorIdOrderByCreatedAtDesc(authorId).stream()
                .map(mapper::toDomain)
                .collect(Collectors.toList());
    }

    @Override
    public boolean hasVoted(UUID feedbackId, UUID voterId) {
        return voteJpaRepository.existsByFeedbackIdAndVoterId(feedbackId, voterId);
    }

    @Override
    public void recordVote(UUID feedbackId, UUID voterId, VoteType voteType) {
        FeedbackVoteEntity voteEntity = new FeedbackVoteEntity();
        try {
            java.lang.reflect.Field idField = com.theMs.sakany.shared.jpa.BaseEntity.class.getDeclaredField("id");
            idField.setAccessible(true);
            idField.set(voteEntity, UUID.randomUUID());
        } catch (Exception e) {
            throw new RuntimeException("Failed to set ID on FeedbackVoteEntity", e);
        }
        voteEntity.setFeedbackId(feedbackId);
        voteEntity.setVoterId(voterId);
        voteEntity.setVoteType(voteType);
        voteJpaRepository.save(voteEntity);
    }

    @Override
    public void deleteById(UUID id) {
        jpaRepository.deleteById(id);
    }
}
