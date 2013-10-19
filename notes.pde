/*

the idea of mystery4 is to have various outputs on robobrrd floating around as particles.
there are also particles floating around that are actions.
and there are small particles that are  'invisible things' that only robots can see, so
  thus they effect the environment.

the environment is made up of the particles and their various strengths, as well as one
  basic rule with regards to the displacement of each particle.
  
if the output particle has not changed its position since the last check, then a velocity
  will be added to that particle, and the particle after it. the velocity would essentially
  send off the two particles in opposite directions. the aim here is to 'mix up' the 
  environment again and stop some of the particles from sticking close together.

the proximities between the output and action particles are observed. the particles that
  have been close over a period of time are noted, and the resulting output-action pair
  will be sent over to the arduino to trigger the real-life action.

---

TODO
add arduino connectivity
add some sort of sensory connection from the robot to the environment


*/
