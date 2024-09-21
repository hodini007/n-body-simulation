# making a n body simulation for 2 charged particle 

# importing the packages 
using Plots
using StaticArrays

#there are three major parts of simulation : body , system and simulation 
#defining the bodies 

struct body
    pos::SVector{Float64,3} # for initial positions in m/s
    vel::SVector{Float64 ,3}# for initial velocities in m/s
    mass::Float64 # for defining mass in kg
    charge::Float64 #defining change in c 
end

# defining constants 

const k = 8.9875517873681764e9 # as we know ,k = 1/(4πϵ) 
const ntime = 500 #defining how many steps taken for the simulation 


# creating a function to calcultae electrostatic force between two bodies 

function eforce(b1::body, b2::body)
    r = b1.pos-b2.pos # return the differences of the cordinates
    s = norm(r) #as we know s=√((x1-x2)^2+(y1-y2)^2)

    magnitude_eforce = (k*b1.charge*b2.charge)/(s^2) # from columbs law 
    direction_eforce = r/s # generates a unit vector for marking the directions

    return magnitude_eforce*direction_eforce


    
end




