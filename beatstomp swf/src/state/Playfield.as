package state
{
  import entity.*;
  import flash.geom.*;
 
  public class Playfield extends State
  {
    public var entities  :Array = [];
    public var particles :Array = [];
    public var draw_order:Array = [];
    
    public var time:int = 0;
        
    public function Playfield(draw_order_:Array = null)
    {
      if(draw_order_ == null) draw_order = [Object];
      else                    draw_order = draw_order_;
    }
    
    override public function tick():void
    {
      super.tick(); 
      for each(var e:Entity   in entities ) e.tick();
      for each(var p:Particle in particles) p.tick();
      
      var i:int;
      for(i=0; i<entities .length; i++)
        if(entities [i].remove) entities .splice(i, 1);
      for(i=0; i<particles.length; i++)
        if(particles[i].remove) particles.splice(i, 1);
      
      time++;
    }
    
    override public function draw():void
    {
      super.draw();
      for each(var kind:Class in draw_order)
      {
        var objects:Array = findEntities(kind);
        objects.sort(function(a:Entity, b:Entity):int
          {
            if(a.position.y+a.foot_offset < b.position.y+b.foot_offset) return -1;
            if(a.position.y+a.foot_offset > b.position.y+b.foot_offset) return  1;
            return 0;
          });
        
        for each(var e:Entity in objects) e.draw();
      }
      for each(var particle:Particle in particles) particle.draw();
    }
    
    public function addEntity(e:Entity):void
    {
      if(e is Particle) particles.push(e);
      else              entities .push(e);
      e.playfield = this;
    }
   
    public function findEntities(type:Class):Array
    {      
      var out:Array = new Array();
      for each(var e:Entity in entities)
        if(e is type && !e.remove) out.push(e);
      return out;
    }
  }
}
