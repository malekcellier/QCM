# 2018-01-24 Integration to psLAB
Wrapper to QCM to be used as interface to psLAB

## Requirements:
- input definition in yaml file
-

## Steps:
- identify QCM inputs
- compare to psLAB inputs

QCM inputs
- freq bins: same for all pow
- antenna array
- universe size
- nb of buildings
- building height distribution
- resolution: house, ground
- materials for: ground, wall, roof, trunk, foliage
    material types (Scatterer, Street, Wood, CMU)
- point of view: TRP with arraygroup, pos, el, az, speed


# Comments
- Street_Material, Wood_Material, .. etc seem to be all the same code with different values => change to factory with parameter files instead
- adaptive atom size like the "meshing" stage of the CFD
- could freqs bins be different for the various pow? or should those be handled by separate sims?
- when psLAB nodes support various freqs, do they have to be grouped ?
- interface to open street maps and mapzen in order to enable automatic maps
- crawler to reduce atom size depending on some criteria (equivalent to "meshing")

# Possible implementation
## Configuration file
YAML file
first level is configuration name. Ex: SimpleTest, MadridTest, etc
Subsequent levels are the various categories
SimpleTest:
  Universe:
    Trees:
      Tree1:
        matTrunk:
        matFoliage
        pos:
    Buildings:
  PointOfViews:
    NW:
      arrayGroup: 
      pov: 

### Decoupling the universe from the pov
Object:
- position: explicit & shape: explicit
- position: explicit & shape: random
- position: random & shape: explicit
- position: random & shape: random
In psLAB, the shape was actually the model
Trees:
- explicit position
- randomly (radius, height)
- randomly (position, radius, height)
Buildings:
- explicit position
- randomly (position, width, depth, height)
- randomly (width, depth, height)

## API
s = QCMSim('configuration')
s.build() %builds the universe with all the atoms etc.
s.addPov(...) % Adds point of views
s.getChannels()
s.applyPrecoder()

## Mapping between QCM concepts and psLAB
