using Plots
using StaticArrays
using LinearAlgebra

# Constants
const k = 8.9875517873681764e9  # Coulomb constant (N·m²/C²)
const dt = 0.01  # Time step for integration
const num_steps = 1000  # Number of simulation steps

# Structure to hold particle data
struct ChargedParticle
    position::SVector{2, Float64}  # (x, y) position
    velocity::SVector{2, Float64}  # (vx, vy) velocity
    charge::Float64  # Charge (in Coulombs)
    mass::Float64    # Mass (in kilograms)
end

# Function to calculate electrostatic force between two charged particles
function coulomb_force(p1::ChargedParticle, p2::ChargedParticle)
    r = p2.position - p1.position  # Vector from p1 to p2
    dist = norm(r)  # Distance between p1 and p2 (magnitude of the vector)
    
    if dist == 0
        return SVector(0.0, 0.0)  # No force if the particles are at the same position (avoid division by zero)
    end
    
    force_magnitude = k * p1.charge * p2.charge / dist^2  # Coulomb's law: magnitude of the force
    force_direction = r / dist  # Unit vector in the direction of the force
    
    return force_magnitude * force_direction  # Vector force: magnitude * direction
end

# Function to update the moving particle (keep the first particle fixed)
function update_particles!(particles::Vector{ChargedParticle})
    f = coulomb_force(particles[1], particles[2])  # Force on the second particle
    acceleration = f / particles[2].mass  # F = ma, so a = F/m
    
    # Update velocity and position of the second particle
    new_velocity = particles[2].velocity + acceleration * dt
    new_position = particles[2].position + new_velocity * dt
    
    # Update the second particle's state
    particles[2] = ChargedParticle(new_position, new_velocity, particles[2].charge, particles[2].mass)
end

# Function to calculate the velocity needed for a circular orbit
function calculate_orbit_velocity(q1, q2, m2, r)
    v = sqrt(k * abs(q1 * q2) / (m2 * r))  # Orbit velocity based on Coulomb force
    return v
end

# Setup for the simulation
r = 1.0  # Distance between the fixed and moving particle (in meters)
q1 = 1e-6  # Charge of the fixed particle (Coulombs)
q2 = -1e-6  # Charge of the moving particle (Coulombs)
m1 = 1.0  # Mass of the fixed particle (irrelevant as it's fixed)
m2 = 0.1  # Mass of the moving particle (adjusted for more visible motion)

# Calculate the orbit velocity for the second particle
v_orbit = calculate_orbit_velocity(q1, q2, m2, r)

# Define initial positions and velocities
particles = [
    ChargedParticle(SVector(0.0, 0.0), SVector(0.0, 0.0), q1, m1),  # Fixed particle at the origin
    ChargedParticle(SVector(r, 0.0), SVector(0.0, v_orbit), q2, m2)  # Moving particle in circular orbit
]

# Visualization setup
animation = @animate for step in 1:num_steps
    # Update the moving particle's position and velocity
    update_particles!(particles)
    
    # Plot the current positions of the particles
    scatter([particles[1].position[1], particles[2].position[1]],  # x-positions
            [particles[1].position[2], particles[2].position[2]],  # y-positions
            xlim=(-r-0.5, r+0.5), ylim=(-r-0.5, r+0.5),  # Fixed plot limits for consistent view
            markersize=8, legend=false, )
    
    # Draw a path trail to see the circular motion
    scatter!([particles[2].position[1]], [particles[2].position[2]], color=:red, markersize=5)
end

# Save the animation as a GIF
gif(animation, "circular_orbit_fixed.gif", fps=30)
