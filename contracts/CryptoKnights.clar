;; CryptoKnights Gaming Platform Smart Contract
;; Handles medieval-themed NFT ownership and trading functionality

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-not-authorized (err u102))
(define-constant err-invalid-input (err u103))
(define-constant err-invalid-price (err u104))
(define-constant max-knight-rank u100)
(define-constant max-honor-points u10000)
(define-constant max-metadata-length u256)
(define-constant max-batch-size u10)  ;; Limit batch operations to prevent potential gas issues

;; Data Variables
(define-map knights 
    { knight-id: uint }
    { owner: principal, metadata-uri: (string-utf8 256), tradeable: bool })

(define-map knight-prices
    { knight-id: uint }
    { price: uint })

(define-map knight-stats
    { player: principal }
    { honor-points: uint, rank: uint })

(define-map tavern-listings
    { knight-id: uint }
    { seller: principal, price: uint, listed-at: uint })

;; Knight Counter
(define-data-var knight-counter uint u0)

;; Helper Functions

;; Validate knight exists and return knight data
(define-private (get-knight-checked (knight-id uint))
    (let ((knight (map-get? knights { knight-id: knight-id })))
        (asserts! (and 
                (is-some knight)
                (<= knight-id (var-get knight-counter)))
            err-not-found)
        (ok (unwrap-panic knight))))

;; Validate metadata URI length
(define-private (validate-metadata-uri (uri (string-utf8 256)))
    (let ((uri-length (len uri)))
        (and 
            (> uri-length u0)
            (<= uri-length max-metadata-length))))

;; Public Functions

;; Batch Mint new knights
(define-public (batch-mint-knights 
    (metadata-uris (list 10 (string-utf8 256))) 
    (tradeable-list (list 10 bool)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (and 
            (> (len metadata-uris) u0)
            (<= (len metadata-uris) max-batch-size)
            (is-eq (len metadata-uris) (len tradeable-list))) 
            err-invalid-input)
        (let ((minted-knights 
            (map mint-single-knight 
                metadata-uris 
                tradeable-list)))
            (ok minted-knights))))

;; Helper function for batch minting
(define-private (mint-single-knight 
    (uri (string-utf8 256))
    (tradeable bool))
    (let 
        ((knight-id (+ (var-get knight-counter) u1)))
        (asserts! (validate-metadata-uri uri) err-invalid-input)
        (map-set knights
            { knight-id: knight-id }
            { owner: contract-owner,
              metadata-uri: uri,
              tradeable: tradeable })
        (var-set knight-counter knight-id)
        (ok knight-id)))

;; Batch Transfer knights
(define-public (batch-transfer-knights 
    (knight-ids (list 10 uint)) 
    (recipients (list 10 principal)))
    (begin
        (asserts! (and 
            (> (len knight-ids) u0)
            (<= (len knight-ids) max-batch-size)
            (is-eq (len knight-ids) (len recipients))) 
            err-invalid-input)
        (let ((transfers 
            (map transfer-single-knight 
                knight-ids 
                recipients)))
            (ok transfers))))

;; Helper function for batch transfer
(define-private (transfer-single-knight 
    (knight-id uint)
    (recipient principal))
    (let 
        ((knight (unwrap-panic (get-knight-checked knight-id))))
        (asserts! (and
                (is-eq (get owner knight) tx-sender)
                (get tradeable knight)
                (not (is-eq recipient tx-sender)))
            err-not-authorized)
        (map-set knights
            { knight-id: knight-id }
            { owner: recipient,
              metadata-uri: (get metadata-uri knight),
              tradeable: (get tradeable knight) })
        (ok true)))

;; List knight in tavern for sale
(define-public (list-knight-in-tavern (knight-id uint) (price uint))
    (begin
        (asserts! (<= knight-id (var-get knight-counter)) err-invalid-input)
        (let ((knight (try! (get-knight-checked knight-id))))
            (asserts! (and 
                    (is-eq (get owner knight) tx-sender)
                    (> price u0)
                    (get tradeable knight))
                err-invalid-price)
            (map-set tavern-listings
                { knight-id: knight-id }
                { seller: tx-sender, 
                  price: price, 
                  listed-at: block-height })
            (ok true))))

;; Purchase knight from tavern
(define-public (purchase-knight (knight-id uint))
    (begin
        (asserts! (<= knight-id (var-get knight-counter)) err-invalid-input)
        (let
            ((knight (try! (get-knight-checked knight-id)))
             (listing (unwrap! (map-get? tavern-listings { knight-id: knight-id }) err-not-found)))
            (asserts! (and
                    (not (is-eq (get seller listing) tx-sender))
                    (get tradeable knight))
                err-not-authorized)
            (try! (stx-transfer? (get price listing) tx-sender (get seller listing)))
            (map-set knights
                { knight-id: knight-id }
                { owner: tx-sender,
                  metadata-uri: (get metadata-uri knight),
                  tradeable: (get tradeable knight) })
            (map-delete tavern-listings { knight-id: knight-id })
            (ok true))))

;; Remove knight from tavern listing
(define-public (remove-from-tavern (knight-id uint))
    (begin
        (asserts! (<= knight-id (var-get knight-counter)) err-invalid-input)
        (let ((listing (unwrap! (map-get? tavern-listings { knight-id: knight-id }) err-not-found)))
            (asserts! (is-eq tx-sender (get seller listing)) err-not-authorized)
            (map-delete tavern-listings { knight-id: knight-id })
            (ok true))))

;; Update knight stats
(define-public (update-knight-stats (honor-points uint) (rank uint))
    (begin
        (asserts! (<= honor-points max-honor-points) err-invalid-input)
        (asserts! (<= rank max-knight-rank) err-invalid-input)
        (map-set knight-stats
            { player: tx-sender }
            { honor-points: honor-points, rank: rank })
        (ok true)))

;; Read-only Functions

;; Get knight details
(define-read-only (get-knight-details (knight-id uint))
    (if (<= knight-id (var-get knight-counter))
        (map-get? knights { knight-id: knight-id })
        none))

;; Get tavern listing details
(define-read-only (get-tavern-listing (knight-id uint))
    (map-get? tavern-listings { knight-id: knight-id }))

;; Get knight stats
(define-read-only (get-knight-stats (player principal))
    (map-get? knight-stats { player: player }))

;; Get total knights minted
(define-read-only (get-total-knights)
    (var-get knight-counter))