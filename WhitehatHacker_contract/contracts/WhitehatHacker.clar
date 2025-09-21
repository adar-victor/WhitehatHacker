
;; title: WhitehatHacker
;; version: 1.0.0
;; summary: Address reputation system for ethical hacker contribution and impact scoring
;; description: This contract manages reputation scores for ethical hackers based on their
;;              contributions, bug reports, and overall impact in the security community.

;; traits
;;

;; token definitions
;;

;; constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-unauthorized (err u101))
(define-constant err-invalid-score (err u102))
(define-constant err-hacker-not-found (err u103))
(define-constant err-already-verified (err u104))
(define-constant err-invalid-contribution (err u105))

;; Maximum reputation score
(define-constant max-reputation-score u10000)
;; Minimum contribution score
(define-constant min-contribution-score u1)
;; Maximum contribution score
(define-constant max-contribution-score u1000)

;; data vars
(define-data-var total-hackers uint u0)
(define-data-var total-contributions uint u0)

;; data maps

;; Hacker profile information
(define-map hacker-profiles
  { hacker: principal }
  {
    reputation-score: uint,
    total-contributions: uint,
    verified: bool,
    registration-block: uint,
    last-activity-block: uint
  }
)

;; Individual contributions made by hackers
(define-map contributions
  { contribution-id: uint }
  {
    hacker: principal,
    contribution-type: (string-ascii 50),
    impact-score: uint,
    verified: bool,
    submission-block: uint,
    verifier: (optional principal)
  }
)

;; Mapping from hacker to their contribution IDs
(define-map hacker-contributions
  { hacker: principal, contribution-index: uint }
  { contribution-id: uint }
)

;; Authorized verifiers who can validate contributions
(define-map authorized-verifiers
  { verifier: principal }
  { authorized: bool }
)

;; public functions

;; Register a new ethical hacker
(define-public (register-hacker)
  (let ((caller tx-sender))
    (asserts! (is-none (map-get? hacker-profiles { hacker: caller })) err-unauthorized)
    (map-set hacker-profiles
      { hacker: caller }
      {
        reputation-score: u0,
        total-contributions: u0,
        verified: false,
        registration-block: block-height,
        last-activity-block: block-height
      }
    )
    (var-set total-hackers (+ (var-get total-hackers) u1))
    (ok true)
  )
)

;; Submit a new contribution
(define-public (submit-contribution (contribution-type (string-ascii 50)) (impact-score uint))
  (let (
    (caller tx-sender)
    (contribution-id (var-get total-contributions))
    (hacker-profile (unwrap! (map-get? hacker-profiles { hacker: caller }) err-hacker-not-found))
  )
    (asserts! (and (>= impact-score min-contribution-score) (<= impact-score max-contribution-score)) err-invalid-contribution)

    ;; Store the contribution
    (map-set contributions
      { contribution-id: contribution-id }
      {
        hacker: caller,
        contribution-type: contribution-type,
        impact-score: impact-score,
        verified: false,
        submission-block: block-height,
        verifier: none
      }
    )

    ;; Link contribution to hacker
    (map-set hacker-contributions
      { hacker: caller, contribution-index: (get total-contributions hacker-profile) }
      { contribution-id: contribution-id }
    )

    ;; Update hacker profile
    (map-set hacker-profiles
      { hacker: caller }
      (merge hacker-profile {
        total-contributions: (+ (get total-contributions hacker-profile) u1),
        last-activity-block: block-height
      })
    )

    (var-set total-contributions (+ contribution-id u1))
    (ok contribution-id)
  )
)

;; Verify a contribution (only authorized verifiers)
(define-public (verify-contribution (contribution-id uint))
  (let (
    (verifier tx-sender)
    (contribution (unwrap! (map-get? contributions { contribution-id: contribution-id }) err-invalid-contribution))
  )
    (asserts! (default-to false (get authorized (map-get? authorized-verifiers { verifier: verifier }))) err-unauthorized)
    (asserts! (not (get verified contribution)) err-already-verified)

    ;; Update contribution as verified
    (map-set contributions
      { contribution-id: contribution-id }
      (merge contribution {
        verified: true,
        verifier: (some verifier)
      })
    )

    ;; Update hacker's reputation score
    (match (map-get? hacker-profiles { hacker: (get hacker contribution) })
      hacker-profile (let ((new-reputation (+ (get reputation-score hacker-profile) (get impact-score contribution))))
        (map-set hacker-profiles
          { hacker: (get hacker contribution) }
          (merge hacker-profile {
            reputation-score: (if (<= new-reputation max-reputation-score) new-reputation max-reputation-score)
          })
        )
        (ok true)
      )
      err-hacker-not-found
    )
  )
)

;; Add authorized verifier (owner only)
(define-public (add-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set authorized-verifiers { verifier: verifier } { authorized: true })
    (ok true)
  )
)

;; Remove authorized verifier (owner only)
(define-public (remove-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set authorized-verifiers { verifier: verifier } { authorized: false })
    (ok true)
  )
)

;; Verify a hacker's profile (owner only)
(define-public (verify-hacker (hacker principal))
  (let ((hacker-profile (unwrap! (map-get? hacker-profiles { hacker: hacker }) err-hacker-not-found)))
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (not (get verified hacker-profile)) err-already-verified)

    (map-set hacker-profiles
      { hacker: hacker }
      (merge hacker-profile { verified: true })
    )
    (ok true)
  )
)

;; read only functions

;; Get hacker profile information
(define-read-only (get-hacker-profile (hacker principal))
  (map-get? hacker-profiles { hacker: hacker })
)

;; Get contribution details
(define-read-only (get-contribution (contribution-id uint))
  (map-get? contributions { contribution-id: contribution-id })
)

;; Get hacker's contribution by index
(define-read-only (get-hacker-contribution (hacker principal) (contribution-index uint))
  (match (map-get? hacker-contributions { hacker: hacker, contribution-index: contribution-index })
    contribution-ref (map-get? contributions { contribution-id: (get contribution-id contribution-ref) })
    none
  )
)

;; Get total number of hackers
(define-read-only (get-total-hackers)
  (var-get total-hackers)
)

;; Get total number of contributions
(define-read-only (get-total-contributions)
  (var-get total-contributions)
)

;; Check if address is authorized verifier
(define-read-only (is-authorized-verifier (verifier principal))
  (default-to false (get authorized (map-get? authorized-verifiers { verifier: verifier })))
)

;; Get hacker's reputation score
(define-read-only (get-reputation-score (hacker principal))
  (match (map-get? hacker-profiles { hacker: hacker })
    profile (some (get reputation-score profile))
    none
  )
)

;; Check if hacker is verified
(define-read-only (is-hacker-verified (hacker principal))
  (match (map-get? hacker-profiles { hacker: hacker })
    profile (get verified profile)
    false
  )
)

;; private functions

;; Calculate reputation tier based on score
(define-read-only (get-reputation-tier (reputation-score uint))
  (if (<= reputation-score u100)
    "Novice"
    (if (<= reputation-score u500)
      "Intermediate"
      (if (<= reputation-score u1500)
        "Advanced"
        (if (<= reputation-score u5000)
          "Expert"
          "Elite"
        )
      )
    )
  )
)
