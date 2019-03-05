(define (domain warehouse)
	(:requirements :typing)
	(:types robot pallette - bigobject
        	location shipment order saleitem)

  	(:predicates
    	(ships ?s - shipment ?o - order)
    	(orders ?o - order ?si - saleitem)
    	(unstarted ?s - shipment)
    	(started ?s - shipment)
    	(complete ?s - shipment)
    	(includes ?s - shipment ?si - saleitem)

    	(free ?r - robot)
    	(has ?r - robot ?p - pallette)

    	(packing-location ?l - location)
    	(packing-at ?s - shipment ?l - location)
    	(available ?l - location)
    	(connected ?l - location ?l - location)
    	(at ?bo - bigobject ?l - location)
    	(no-robot ?l - location)
    	(no-pallette ?l - location)

    	(contains ?p - pallette ?si - saleitem)
  )

   (:action startShipment
      :parameters (?s - shipment ?o - order ?l - location)
      :precondition (and (unstarted ?s) (not (complete ?s)) (ships ?s ?o) (available ?l) (packing-location ?l))
      :effect (and (started ?s) (packing-at ?s ?l) (not (unstarted ?s)) (not (available ?l)))
   )
   
   (:action pickup 
      ; requires a robot, pallette and location
      :parameters (?r - robot ?p - pallette ?l - location)
      
      ; The robot has to be free and the pallette and robot have to be in the same location
      :precondition (and
                    (free ?r)
                    (at ?p ?l)
                    (at ?r ?l)
                    )
                    
      ; The robot now has the pallet and is marked as not free
      :effect (and 
              (has ?r ?p)
              (not (free ?r))
              )
   )
   
   (:action putdown
      ; Requires a robot, location and pallette
      :parameters (?r - robot ?p - pallette ?l - location)
      
      ; The robot has to have the pallete, they have to be in the same location
      :precondition (and
                    (has ?r ?p)
                    (not (free ?r))
                    (at ?r ?l)
                    (at ?p ?l) 
                    )
                    
      ; The robot no longer has the pallette and is marked as free
      :effect (and 
              (not (has ?r ?p))
              (free ?r)
              )
   )

    (:action robotMove
   
     :parameters (?r - robot ?l1 - location ?l2 - location)
     :precondition (and
                   (connected ?l1 ?l2)
                   (at ?r ?l1)
                   (no-robot ?l2)
                   (free ?r)
                   )
     :effect (and
             (at ?r ?l2)
             (not (at ?r ?l1))
             (not (no-robot ?l2))
             (no-robot ?l1)
             )
     
    )

   (:action robotMoveWithPallette
     ; There needs to be a Robot, start location, end location, and a pallette
     :parameters (?r - robot ?l1 - location ?l2 - location ?p - pallette)
     
     ; The Robot needs to have the Pallette and be in the initial location with the pallete.
     ; The locations need to be connected and the end location needs to not have a robot or pallette currently there.
     :precondition (and
                   (has ?r ?p) ;robot has pallette
                   (not (free ?r)) 
                   (connected ?l1 ?l2) ; locations are connected
                   (at ?r ?l1) ;robot and pallete are in l1
                   (at ?p ?l1)
                   (no-robot ?l2) ;l2 is free and r can move into it
                   (no-pallette ?l2)
                   )
     ; The Robot and the pallettes location need to be switched. 
     ; L1 needs to be marked as free of robot and pallette and L2 needs to be marked with them
     :effect (and 
             (at ?r ?l2) ; switching robot and pallette locations
             (at ?p ?l2)
             (not (at ?r ?l1))
             (not (at ?p ?l1))
             (no-pallette ?l1); marking l1 as free of robot and pallette
             (no-robot ?l1)
             (not (no-pallette ?l2)); marking l2 with robot and pallette
             (not (no-robot ?l2))
             )
     
   )
   
   
   
   (:action moveItemFromPalletteToShipment
     ; Requires a location , a shipment,  a saleitem, a palette, and an order
     :parameters (?l - location ?s - shipment ?i - saleitem ?p - pallette ?o - order)
     
     ; The pallette needs to be at the location
     ; The pallette needs an item that the order still needs
     ; The location needs to be a packing location
     ; The shipment needs to be being packed at the location
     ; The shipment needs to ship the order that were packing for
     ; The shipment needs to be started
     :precondition (and 
                   (at ?p ?l)
                   (orders ?o ?i)
                   (contains ?p ?i)
                   (packing-at ?s ?l)
                   (ships ?s ?o)
                   (started ?s)
                   )
     ; The i is transfered from the pallete to the shipment 
     :effect (and 
             (not (contains ?p ?i))
             (includes ?s ?i)
             )
   )
   
   
   (:action completeShipment
     :parameters (?s -shipment ?o - order ?i -saleitem ?l - location)
     :precondition (and
                   (ships ?s ?o)
                   (orders ?o ?i)
                   (includes ?s ?i)
      )
     :effect (and
             (not (started ?s))
             (complete ?s)
             (available ?l)
             (not (packing-at ?s ?l))
             (not (ships ?s ?o))
             (not (orders ?o ?i))
      )
   )
)


